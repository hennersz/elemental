{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.elemental.home.program.editor.neovim;
  claudeModel = "claude-sonnet-5";
in
{
  options.elemental.home.program.editor.neovim = {
    enable = mkEnableOption "Enable neovim";
    anthropicApiKeyRef = mkOption {
      type = types.str;
      description = "1password secret reference used to populate ANTHROPIC_API_KEY";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withRuby = false;
      withPython3 = false;

      # General-purpose LSP servers that don't need to track a specific
      # project's pinned toolchain version -- installed globally so they
      # work out of the box everywhere. direnv prepends a project's own
      # devShell binaries onto $PATH ahead of these, so a project that does
      # pin its own copy of one of these will still take precedence.
      extraPackages = with pkgs; [
        fish-lsp
        bash-language-server
        vscode-langservers-extracted # jsonls
        yaml-language-server
        marksman
        gopls
        nil
      ];

      initLua = mkMerge [
        # nixpkgs builds avante's native libs (avante_templates, avante_tokenizers, ...) as
        # .dylib on Darwin. Neovim's rtp-aware native module loader (vim._load_package) only
        # looks for the suffix patterns it captured from package.cpath at startup, which is
        # .so-only even on Darwin, so it never finds these unless we add the .dylib trail.
        (mkIf pkgs.stdenv.isDarwin (mkOrder 50 ''
          table.insert(vim._so_trails, '/?.dylib')
        ''))

        # `:q` only closes the current window, so with Avante's chat sidebar and
        # Neo-tree's file explorer both open alongside the file buffer, quitting
        # takes 3 separate `:q`s. `:qa` closes every window and exits Neovim in
        # one shot (still refuses to quit if there are unsaved changes; use the
        # `!` variant to discard them and force-quit regardless).
        (mkOrder 50 ''
          vim.keymap.set('n', '<leader>qq', ':qa<CR>',  { desc = 'Quit all windows' })
          vim.keymap.set('n', '<leader>qQ', ':qa!<CR>', { desc = 'Quit all windows (discard changes)' })
        '')

        # Move between windows (e.g. Neo-tree <-> file buffer <-> Trouble)
        # with the same hjkl direction keys used for normal movement.
        (mkOrder 50 ''
          vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to window left' })
          vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
          vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })
          vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to window right' })
        '')

        (mkOrder 50 ''
          vim.opt.wrap = false
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.fillchars = { eob = ' ' }
          vim.opt.tabstop = 2
          vim.opt.shiftwidth = 2
          vim.opt.expandtab = true
          vim.opt.winborder = 'rounded'
          vim.opt.updatetime = 250
        '')

        # Mirror VSCode's "render whitespace" defaults: a middle dot for spaces,
        # an arrow filling the tab width.
        (mkOrder 50 ''
          vim.opt.list = true
          vim.opt.listchars = {
            tab = '→ ',
            space = '·',
            trail = '·',
            nbsp = '␣',
          }
        '')
      ];

      plugins = with pkgs.vimPlugins; [
        # ── Dependencies ──────────────────────────────────────────────────────
        plenary-nvim
        nui-nvim
        nvim-web-devicons

        # ── Colorscheme: Solarized ──────────────────────────────────────────
        # Placed early so it's applied before plugins that read colors at setup
        # time (e.g. lualine's bundled 'solarized' theme below).
        {
          plugin = solarized-nvim;
          type = "lua";
          config = ''
            vim.o.background = 'light'
            vim.g.solarized_italic_comments = true
            vim.g.solarized_contrast = true
            require('solarized').set()
          '';
        }

        # ── AI: Avante (chat / edit) ──────────────────────────────────────────
        {
          plugin = avante-nvim;
          type = "lua";
          config = ''
            -- avante's built-in claude defaults hardcode extra_request_body.temperature,
            -- which several newer models (Opus 4.7/4.8, Sonnet 5, Fable 5) reject outright
            -- ("`temperature` is deprecated for this model"). Since avante deep-merges our
            -- config over its own defaults, omitting `temperature` on our side isn't enough
            -- to remove it -- we patch it out of avante's defaults table before setup runs,
            -- so it's never present for any model selected via the runtime model picker.
            local avante_defaults = require('avante.config')._defaults
            if avante_defaults.providers.claude and avante_defaults.providers.claude.extra_request_body then
              avante_defaults.providers.claude.extra_request_body.temperature = nil
            end

            require('avante').setup({
              provider = 'claude',
              selector = {
                provider = 'telescope',
              },
              providers = {
                claude = {
                  model = '${claudeModel}',
                  model_names = {
                    'claude-fable-5',
                    'claude-opus-4-8',
                    'claude-sonnet-5',
                    'claude-haiku-4-5',
                  },
                },
              },
              mappings = {
                ask = '<leader>aa',
                edit = '<leader>ae',
                select_model = '<leader>am',
                -- avante's own default for select_acp_mode is also <leader>am; move it
                -- out of the way (its config value must be a string -- `false` crashes
                -- avante's keymap setup, since it's passed straight to vim.keymap.set)
                select_acp_mode = '<leader>aP',
                toggle = {
                  default = '<leader>at',
                },
              },
            })

            -- Upstream bug (present in avante's tokenizers.lua as of 2026-07, unfixed on
            -- main): when the native Rust tokenizer fails to encode a prompt (e.g. bash
            -- tool output containing invalid UTF-8), avante's own error handler does
            -- `"..." .. result`, but `result` is a Rust error object (userdata), not a
            -- string -- so the "graceful" handler itself throws. Wrap the whole (buggy)
            -- function in our own pcall so both failure modes degrade to a safe nil.
            do
              local tokenizers = require('avante.tokenizers')
              local original_encode = tokenizers.encode
              tokenizers.encode = function(prompt)
                local ok, result = pcall(original_encode, prompt)
                if not ok then
                  vim.schedule(function()
                    vim.notify('avante: failed to encode prompt for token counting: ' .. tostring(result), vim.log.levels.WARN)
                  end)
                  return nil
                end
                return result
              end
            end
          '';
        }

        # ── AI: Minuet (inline completion) ────────────────────────────────────
        {
          plugin = minuet-ai-nvim;
          type = "lua";
          config = ''
            require('minuet').setup({
              provider = 'claude',
              provider_options = {
                claude = {
                  model = '${claudeModel}',
                },
              },
              virtualtext = {
                auto_trigger_ft = { '*' },
                keymap = {
                  accept = '<A-a>',
                  accept_line = '<A-l>',
                  prev = '<A-[>',
                  next = '<A-]>',
                  dismiss = '<A-e>',
                },
              },
            })
          '';
        }

        # ── AI: Claude Code ───────────────────────────────────────────────────
        {
          plugin = claudecode-nvim;
          type = "lua";
          config = ''
            require('claudecode').setup({
              terminal = { split_side = 'right', split_width_percentage = 0.35 },
            })
            vim.keymap.set('n', '<leader>kk', ':ClaudeCode<CR>',            { desc = 'Toggle Claude Code' })
            vim.keymap.set('n', '<leader>kf', ':ClaudeCodeFocus<CR>',       { desc = 'Focus Claude Code' })
            vim.keymap.set('n', '<leader>kb', ':ClaudeCodeAdd %<CR>',       { desc = 'Add buffer to context' })
            vim.keymap.set('v', '<leader>ks', ':ClaudeCodeSend<CR>',        { desc = 'Send selection to Claude' })
            vim.keymap.set('n', '<leader>ka', ':ClaudeCodeDiffAccept<CR>',  { desc = 'Accept Claude diff' })
            vim.keymap.set('n', '<leader>kd', ':ClaudeCodeDiffDeny<CR>',    { desc = 'Deny Claude diff' })
          '';
        }

        # ── Markdown rendering ─────────────────────────────────────────────────
        {
          plugin = render-markdown-nvim;
          type = "lua";
          config = "require('render-markdown').setup({})";
        }

        # ── Completion: blink-cmp (wires LSP + AI sources) ────────────────────
        blink-cmp-avante

        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require('blink-cmp').setup({
              keymap = {
                preset = 'default',
                ['<A-y>'] = require('minuet').make_blink_map(),
              },
              sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet', 'avante' },
                providers = {
                  minuet = {
                    name = 'minuet',
                    module = 'minuet.blink',
                    async = true,
                    timeout_ms = 3000,
                    score_offset = 50,
                  },
                  avante = {
                    module = 'blink-cmp-avante',
                    name = 'Avante',
                  },
                },
              },
              completion = {
                trigger = { prefetch_on_insert = false },
                documentation = {
                  auto_show = true,
                  auto_show_delay_ms = 200,
                },
                menu = {
                  draw = {
                    columns = {
                      { 'kind_icon' },
                      { 'label', 'label_description', gap = 1 },
                      { 'kind' },
                    },
                  },
                },
              },
              signature = { enabled = true },
            })
          '';
        }

        # ── LSP ───────────────────────────────────────────────────────────────
        # Note: in a nix-managed setup, prefer installing LSP servers via
        # programs.neovim.extraPackages rather than mason's own downloader.
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            -- nvim-lspconfig >= 0.11 style: it now just ships default server
            -- definitions (lsp/*.lua) consumed via the native vim.lsp.config()
            -- / vim.lsp.enable() API. The old require('lspconfig')[name].setup()
            -- framework is deprecated and slated for removal in v3.0.0.

            -- OpenTofu's own extension; treat it as terraform so treesitter
            -- and terraform-ls both pick it up.
            vim.filetype.add({ extension = { tofu = 'terraform' } })

            -- Common on_attach: set keymaps when an LSP attaches to a buffer
            local on_attach = function(_, bufnr)
              local opts = { buffer = bufnr }
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,     vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
              vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,    vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
              vim.keymap.set('n', 'gr',         vim.lsp.buf.references,     vim.tbl_extend('force', opts, { desc = 'Go to references' }))
              vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
              vim.keymap.set('n', 'K',          vim.lsp.buf.hover,          vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
              vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,         vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
              vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,    vim.tbl_extend('force', opts, { desc = 'Code action' }))
              vim.keymap.set('n', '<leader>d',  vim.diagnostic.open_float,  vim.tbl_extend('force', opts, { desc = 'Show diagnostics' }))
              vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,   vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
              vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,   vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
            end

            -- Applied as defaults to every server enabled below.
            vim.lsp.config('*', { on_attach = on_attach })

            -- yamlls needs extra settings to recognise GitHub Actions
            -- workflow files and validate/autocomplete against their schema.
            vim.lsp.config('yamlls', {
              settings = {
                yaml = {
                  schemas = {
                    ['https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/github-workflow.json'] = '/.github/workflows/*.{yml,yaml}',
                  },
                },
              },
            })

            vim.lsp.config('gopls', {
              settings = {
                gopls = {
                  hints = {
                    parameterNames = true,
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    rangeVariableTypes = true,
                  },
                },
              },
            })

            vim.api.nvim_create_autocmd('CursorHold', {
              callback = function()
                vim.diagnostic.open_float(nil, { focusable = false, scope = 'cursor' })
              end,
            })

            -- terraformls is deliberately not installed via extraPackages:
            -- terraform-ls/tofu track a specific project's IaC toolchain, so
            -- that one should come from the project's own nix devShell/direnv
            -- setup rather than a global version. Everything else here is
            -- installed globally via extraPackages above. Either way, vim.lsp
            -- resolves servers by plain command name against $PATH once a
            -- matching buffer opens.
            vim.lsp.enable({ 'terraformls', 'yamlls', 'fish_lsp', 'bashls', 'jsonls', 'marksman', 'gopls', 'nil_ls' })

            -- goimports-on-save equivalent (what VS Code's Go extension does):
            -- gopls's plain textDocument/formatting only runs gofmt, it doesn't
            -- add/remove imports. Run the source.organizeImports code action on
            -- every Go save too. Registered before conform's format_on_save
            -- autocmd (below, in the Formatting section) so imports get sorted
            -- first and gofmt runs after.
            vim.api.nvim_create_autocmd('BufWritePre', {
              pattern = '*.go',
              callback = function()
                local params = vim.lsp.util.make_range_params()
                params.context = { only = { 'source.organizeImports' } }
                local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 1000)
                for _, res in pairs(results or {}) do
                  for _, action in pairs(res.result or {}) do
                    if action.edit then
                      vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
                    end
                  end
                end
              end,
            })
          '';
        }

        {
          plugin = mason-nvim;
          type = "lua";
          config = "require('mason').setup()";
        }

        {
          plugin = mason-lspconfig-nvim;
          type = "lua";
          config = ''
            require('mason-lspconfig').setup({
              ensure_installed = {},
              automatic_installation = false,
            })
          '';
        }

        # ── Treesitter (syntax highlighting & code understanding) ──────────────
        # nvim-treesitter's `main` branch (what nixpkgs packages) dropped the old
        # `nvim-treesitter.configs` setup API; highlight/indent are now enabled
        # per-buffer via the built-in vim.treesitter functions. Grammars are
        # provided by nix (withAllGrammars), so no installer/setup call is needed.
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            vim.api.nvim_create_autocmd('FileType', {
              callback = function()
                pcall(vim.treesitter.start)
                pcall(function() vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end)
              end,
            })

            -- solarized.nvim hardcodes the base 'String' group to italic with
            -- no toggle (unlike its Comment/Keyword/Function/Variable groups).
            -- Since YAML values are almost all plain-scalar strings, that
            -- makes nearly the whole document italic. Override just the
            -- YAML-specific link so other languages keep italic strings.
            local string_hl = vim.api.nvim_get_hl(0, { name = 'String' })
            string_hl.italic = false
            vim.api.nvim_set_hl(0, '@string.yaml', string_hl)
          '';
        }

        # ── Formatting ────────────────────────────────────────────────────────
        {
          plugin = conform-nvim;
          type = "lua";
          config = ''
            require('conform').setup({
              formatters_by_ft = {
                -- lua        = { 'stylua' },
                -- nix        = { 'nixfmt' },
                -- javascript = { 'prettier' },
                terraform = { 'terraform_fmt' },
              },
              formatters = {
                -- conform's built-in terraform_fmt runs `terraform fmt`; point
                -- it at `tofu` instead, resolved from whatever project shell
                -- provides it.
                terraform_fmt = {
                  command = 'tofu',
                },
              },
              format_on_save = {
                timeout_ms = 500,
                lsp_format = 'fallback',
              },
            })
          '';
        }

        # ── File explorer ─────────────────────────────────────────────────────
        {
          plugin = neo-tree-nvim;
          type = "lua";
          config = ''
            require('neo-tree').setup({
              filesystem = {
                use_libuv_file_watcher = true,
                filtered_items = {
                  hide_dotfiles = false,
                  hide_gitignored = false,
                },
                follow_current_file = { enabled = true },
              },
              window = { width = 35 },
            })
            vim.keymap.set('n', '<leader>fe', ':Neotree toggle<CR>', { desc = 'Toggle file explorer' })
            vim.keymap.set('n', '<leader>fo', ':Neotree reveal<CR>', { desc = 'Reveal current file in explorer' })
          '';
        }

        # ── Fuzzy finder ──────────────────────────────────────────────────────
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            require('telescope').setup({
              defaults = {
                mappings = {
                  i = { ['<C-u>'] = false, ['<C-d>'] = false },
                },
              },
            })
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files,           { desc = 'Find files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep,            { desc = 'Live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers,              { desc = 'Find buffers' })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags,            { desc = 'Help tags' })
            vim.keymap.set('n', '<leader>fr', builtin.oldfiles,             { desc = 'Recent files' })
            vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
            vim.keymap.set('n', '<leader>fw', builtin.grep_string,          { desc = 'Find word under cursor' })
          '';
        }

        # ── Status bar ────────────────────────────────────────────────────────
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup({
              options = {
                theme = 'solarized',
                component_separators = '|',
                section_separators = "",
              },
              sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = { 'encoding', 'fileformat', 'filetype' },
                lualine_y = { 'progress' },
                lualine_z = { 'location' },
              },
            })
          '';
        }

        # ── Buffer tab bar ────────────────────────────────────────────────────
        {
          plugin = bufferline-nvim;
          type = "lua";
          config = ''
            require('bufferline').setup({
              options = {
                diagnostics = 'nvim_lsp',
                show_buffer_close_icons = true,
                show_close_icon = false,
                separator_style = 'slant',
              },
            })
            vim.keymap.set('n', '<Tab>',      ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
            vim.keymap.set('n', '<S-Tab>',    ':BufferLineCyclePrev<CR>', { desc = 'Prev buffer' })
            vim.keymap.set('n', '<leader>bd', ':bdelete<CR>',             { desc = 'Close buffer' })
          '';
        }

        # ── Diagnostics panel ─────────────────────────────────────────────────
        {
          plugin = trouble-nvim;
          type = "lua";
          config = ''
            require('trouble').setup({})
            vim.keymap.set('n', '<leader>xx', ':Trouble diagnostics toggle<CR>',                        { desc = 'Toggle diagnostics (workspace)' })
            vim.keymap.set('n', '<leader>xd', ':Trouble diagnostics toggle filter.buf=0<CR>',           { desc = 'Toggle diagnostics (buffer)' })
            vim.keymap.set('n', '<leader>xs', ':Trouble symbols toggle focus=false<CR>',                { desc = 'Toggle symbols' })
            vim.keymap.set('n', '<leader>xl', ':Trouble lsp toggle focus=false win.position=right<CR>', { desc = 'Toggle LSP references' })
          '';
        }

        # ── Git signs & inline blame ──────────────────────────────────────────
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            require('gitsigns').setup({
              signs = {
                add          = { text = '+' },
                change       = { text = '~' },
                delete       = { text = '_' },
                topdelete    = { text = '^' },
                changedelete = { text = '~' },
              },
              on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local opts = { buffer = bufnr }
                vim.keymap.set('n', ']c',         gs.next_hunk,    vim.tbl_extend('force', opts, { desc = 'Next git hunk' }))
                vim.keymap.set('n', '[c',         gs.prev_hunk,    vim.tbl_extend('force', opts, { desc = 'Prev git hunk' }))
                vim.keymap.set('n', '<leader>gb', gs.blame_line,   vim.tbl_extend('force', opts, { desc = 'Git blame line' }))
                vim.keymap.set('n', '<leader>gp', gs.preview_hunk, vim.tbl_extend('force', opts, { desc = 'Preview git hunk' }))
                vim.keymap.set('n', '<leader>gs', gs.stage_hunk,   vim.tbl_extend('force', opts, { desc = 'Stage hunk' }))
                vim.keymap.set('n', '<leader>gr', gs.reset_hunk,   vim.tbl_extend('force', opts, { desc = 'Reset hunk' }))
                vim.keymap.set('n', '<leader>gd', gs.diffthis,     vim.tbl_extend('force', opts, { desc = 'Diff this file' }))
              end,
            })
          '';
        }

        # ── Diff review ───────────────────────────────────────────────────────
        {
          plugin = diffview-nvim;
          type = "lua";
          config = ''
            require('diffview').setup({})
            vim.keymap.set('n', '<leader>gv', ':DiffviewOpen<CR>',          { desc = 'Open diff view' })
            vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory %<CR>', { desc = 'File history' })
            vim.keymap.set('n', '<leader>gq', ':DiffviewClose<CR>',         { desc = 'Close diff view' })
          '';
        }

        # ── Project-wide search & replace ─────────────────────────────────────
        {
          plugin = grug-far-nvim;
          type = "lua";
          config = ''
            require('grug-far').setup({})
            vim.keymap.set('n', '<leader>sr', function() require('grug-far').open() end, { desc = 'Search and replace' })
            vim.keymap.set('n', '<leader>sw', function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } }) end, { desc = 'Replace word under cursor' })
            vim.keymap.set('v', '<leader>sr', function() require('grug-far').with_visual_selection() end, { desc = 'Replace selection' })
          '';
        }

        # ── Which-key (keybinding popup) ──────────────────────────────────────
        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            require('which-key').setup({ delay = 500 })
            require('which-key').add({
              { '<leader>a', group = 'AI (Avante)' },
              { '<leader>b', group = 'Buffer' },
              { '<leader>c', group = 'Code' },
              { '<leader>f', group = 'Find (Telescope)' },
              { '<leader>g', group = 'Git' },
              { '<leader>k', group = 'Claude Code' },
              { '<leader>q', group = 'Quit' },
              { '<leader>r', group = 'Rename' },
              { '<leader>s', group = 'Search and replace' },
              { '<leader>t', group = 'Toggle' },
              { '<leader>x', group = 'Diagnostics (Trouble)' },
            })
          '';
        }

        # ── Auto-pairs ────────────────────────────────────────────────────────
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = ''
            require('nvim-autopairs').setup({
              check_ts = true, -- use treesitter for smarter pairing
            })
          '';
        }

        # ── Commenting ────────────────────────────────────────────────────────
        {
          plugin = comment-nvim;
          type = "lua";
          config = "require('Comment').setup({})";
        }

        # ── Indent guides ─────────────────────────────────────────────────────
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config = ''
            -- Solarized light base2 -- a couple shades darker than the base3
            -- background, faint enough to read as a hint rather than a line.
            vim.api.nvim_set_hl(0, 'IndentLineFaint', { fg = '#eee8d5' })
            -- listchars glyphs (tab/space/trail/nbsp) are drawn with the
            -- 'Whitespace' highlight group; set here (rather than in initLua)
            -- since plugin configs -- including the colorscheme -- run after
            -- initLua and would otherwise clobber this override.
            vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#eee8d5' })
            require('ibl').setup({
              enabled = false,
              indent = { char = '|', highlight = 'IndentLineFaint' },
              scope  = { enabled = true },
            })
            vim.keymap.set('n', '<leader>ti', ':IBLToggle<CR>', { desc = 'Toggle indent guides' })
          '';
        }

        # ── Minimap & outline ─────────────────────────────────────────────────
        {
          plugin = pkgs.vimUtils.buildVimPlugin {
            pname = "neominimap-nvim";
            version = "3.16.0";
            src = pkgs.fetchFromGitHub {
              owner = "Isrothy";
              repo = "neominimap.nvim";
              rev = "v3.16.0";
              hash = "sha256-EcV/mdleyopQsJ/t/Whl6Yf/2ORb9rnhHuc2Ue1E1Bw=";
            };
            doCheck = false;
          };
          type = "lua";
          config = ''
            vim.g.neominimap = {
              auto_enable = false,
              layout = 'float',
              float = { minimap_width = 14, window_border = 'none' },
              treesitter = { enabled = true },
              click = { enabled = true },
            }
            vim.keymap.set('n', '<leader>tm', ':Neominimap Toggle<CR>', { desc = 'Toggle minimap' })
          '';
        }

        {
          plugin = aerial-nvim;
          type = "lua";
          config = ''
            require('aerial').setup({
              backends = { 'lsp', 'treesitter' },
              layout = { default_direction = 'right', min_width = 30 },
              show_guides = true,
            })
            vim.keymap.set('n', '<leader>to', ':AerialToggle!<CR>', { desc = 'Toggle outline' })
          '';
        }

        {
          plugin = nvim-treesitter-context;
          type = "lua";
          config = "require('treesitter-context').setup({ max_lines = 3 })";
        }

        # ── Integrated terminal ───────────────────────────────────────────────
        {
          plugin = toggleterm-nvim;
          type = "lua";
          config = ''
            require('toggleterm').setup({
              open_mapping = [[<C-t>]],
              direction = 'float',
              float_opts = { border = 'curved' },
            })
          '';
        }
      ];
    };

    xdg.configFile."fish/conf.d/anthropicApiKey.fish" = mkIf (cfg.anthropicApiKeyRef != "") {
      text = ''
        if not set -q ANTHROPIC_API_KEY
          set -Ux ANTHROPIC_API_KEY (op read "${cfg.anthropicApiKeyRef}")
        end
      '';
    };
  };
}

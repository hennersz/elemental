{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.elemental.home.program.editor.nvim;
in
{
  options.elemental.home.program.editor.nvim = {
    enable = mkEnableOption "Enable nvim";
  };

  config = mkIf cfg.enable {
    programs.nixneovim = {
      enable = true;
      options = {
        number = true;
      };
      
      # to install plugins just activate their modules
      plugins = {
        treesitter = {
          enable = true;
          indent = true;
        };
        telescope = {
          enable = true;
        };
        which-key.enable = true;
        lualine.enable = true;
      };

      extraPlugins = with pkgs.vimExtraPlugins; [ 
        neo-tree-nvim
        nui-nvim
        plenary-nvim
        nvim-web-devicons
      ];
      extraConfigLua = ''
      vim.wo.fillchars='eob: '
      vim.opt.fillchars = { eob = " "}
      require("neo-tree").setup({})
      '';
    };
    # xdg.configFile."nvim/lua/" = {
    #   source = ./config/lua;
    #   recursive = true;
    # };
    # xdg.configFile."nvim/init.lua" = {
    #   source = ./config/init.lua;
    # };
    # xdg.configFile."nvim/stylua.toml" = {
    #   source = ./config/stylua.toml;
    # };
    # xdg.configFile."nvim/.neoconf.json" = {
    #   source = ./config/.neoconf.json;
    # };
  };
}
{ config, lib, pkgs, ...}:
with lib;
let 
  cfg = config.elemental.home.program.editor.vscode;
in
{
  options.elemental.home.program.editor.vscode = {
    enable = mkEnableOption "Enable vscode";
  };

  config = mkIf cfg.enable {
    elemental.home.program.dev.git.extraConfig.core.editor = "code --wait --reuse-window";

    home.file.extensions = {
      source = ./extensions.list;
      target = ".config/Code/extensions.list";
      onChange = "cat ~/.config/Code/extensions.list | grep -v '^#' | xargs -L1 code --install-extension --force";
    };

    home.activation = { 
      linkCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.xdg.configHome}/Code && \
          ln -sf $VERBOSE_ARG \
          ${builtins.toString ./settings.json} \
          ${config.xdg.configHome}/Code/User/settings.json && \
          ln -sf $VERBOSE_ARG \
          ${builtins.toString ./keybindings.json} \
          ${config.xdg.configHome}/Code/User/keybindings.json && \
      '';
    };
  };

}
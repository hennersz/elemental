{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "darwin-laptop") {
    elemental.home.program = {
      terminal.iterm2.enable = true;
      editor.vscode.enable = true;
    };

    home.activation = {
      codeUseConfDir = lib.hm.dag.entryAfter ["linkCode"] ''
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG ${config.xdg.configHome}/Code/User ~/Library/Application Support/Code
      '';
    };

    nixpkgs.config.allowUnfree = true;

    # Environment
    home.sessionVariables = {
      EDITOR = "code";
      BROWSER = "firefox";
      TERMINAL = "iterm2";
    };


    programs.gpg = {
      enable = true;
    };
  };
}

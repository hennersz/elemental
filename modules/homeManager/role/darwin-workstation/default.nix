{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "darwin-laptop") {
    elemental.home.program = {
      terminal.iterm2.enable = false;
      editor.vscode.enable = true;
      editor.neovim.enable = true;
    };

    home = {
      activation = {
        codeUseConfDir = lib.hm.dag.entryAfter [ "linkCode" ] ''
          $DRY_RUN_CMD ln -sfn $VERBOSE_ARG ${config.xdg.configHome}/Code/User ~/Library/Application\ Support/Code/User
        '';
      };

      # Environment
      sessionVariables = {
        EDITOR = "code --wait";
        BROWSER = "firefox";
        TERMINAL = "iterm2";
      };

      packages = with pkgs; [
        regctl
      ];
    };
  };
}

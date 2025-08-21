{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "linux-workstation") {
    elemental.home.program = {
      editor.vscode.enable = true;
    };

    # Environment
    home.sessionVariables = {
      EDITOR = "code --wait";
    };

    home.packages = with pkgs; [
      regctl
    ];
  };
}

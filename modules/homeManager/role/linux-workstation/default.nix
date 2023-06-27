{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "linux-workstation" || config.elemental.role == "nixos-workstation") {
    elemental.home.program = {
      editor.vscode.enable = true;
    };

    # Environment
    home.sessionVariables = {
      EDITOR = "code --wait";
    };
  };
}

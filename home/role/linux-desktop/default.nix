{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "linux-desktop") {
    elemental.home.program = {
      editor.vscode.enable = true;
    };

    # Environment
    home.sessionVariables = {
      EDITOR = "code --wait";
    };

    home.packages = with pkgs; [
      buildah
      docker
      podman
      vscode
      pdfarranger
    ];
  };
}

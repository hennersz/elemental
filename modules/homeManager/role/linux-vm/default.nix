{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "linux-vm") {
    # Environment
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.packages = with pkgs; [
      buildah
      docker
      podman
      traceroute
    ];
  };
}

{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "controlPlane") {
    elemental.home.program.credentials.onePassword = {
      enable = true;
      account = "controlplanelimited";
    };
  };
}

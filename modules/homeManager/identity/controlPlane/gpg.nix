{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "controlPlane") {
    elemental.home.program.credentials.gpg = {
      enable = true;
      settings.default-key = "05E292FFA4E813C7A073F3364F3E2B6A725471AD";
    };
  };
}

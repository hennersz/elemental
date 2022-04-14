{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "controlPlane") {
    programs.password-store.settings = {
      PASSWORD_STORE_SIGNING_KEY = "05E292FFA4E813C7A073F3364F3E2B6A725471AD";
    };
  };
}
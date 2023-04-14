{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "controlPlane") {
    programs.password-store.settings = {
      PASSWORD_STORE_SIGNING_KEY = "2BE0BAB0E0F81C7EFC992F5EA9361CEA6825688D";
    };
  };
}
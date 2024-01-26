{ config, lib, pkgs, ... }:
with lib;
{
  config = lib.mkIf (config.elemental.machine == "fenrir") {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/home/henry/Credentials/passwords";
      };
    };
  };
}

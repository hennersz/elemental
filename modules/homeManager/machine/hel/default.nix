{ config, lib, ... }:
with lib;
{
  config = lib.mkIf (config.elemental.machine == "hel") {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/home/henry/Credentials/passwords";
      };
    };
  };
} 
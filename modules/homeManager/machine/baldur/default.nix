{ config, lib, ... }:
{
  config = lib.mkIf (config.elemental.machine == "baldur") {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/Users/henry/Credentials/passwords";
      };
    };
  };
}

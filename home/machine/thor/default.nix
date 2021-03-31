{ config, lib, ... }:
{
  config = lib.mkIf (config.elemental.machine == "thor") {
    elemental.home.program.credentials.gpg.home = "/Users/henry/Credentials/gpg";
    home.sessionVariables = {
      ELEMENTAL_SOURCE_DIR = "/Users/henry/.config/nixpkgs";
    };
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/Users/henry/Credentials/passwords";
      };
    };
  };
} 
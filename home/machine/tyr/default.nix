{ config, lib, ... }:
with lib;
{
  config = lib.mkIf (config.elemental.machine == "tyr") {
    home.sessionVariables = {
      ELEMENTAL_SOURCE_DIR = "/home/henry/.config/nixpkgs";
    };
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/home/henry/Credentials/passwords";
      };
    };
  };
} 
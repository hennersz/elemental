{ config, lib, ... }:
{
  config = lib.mkIf (config.elemental.machine == "thor") {
    home.sessionVariables = {
      ELEMENTAL_SOURCE_DIR = "/Users/henry/.config/nixpkgs";
    };
  };
} 
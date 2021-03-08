{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "personal") {
    elemental.home.program.dev.git = {
      enable = true;

      userEmail = "henry@morti.net";
      userName = "hennersz";
      extraConfig =  {
        url = {
          "git@github.com:" = {
            insteadOf = "https://github.com/";
          };
        };
      };
    };
  };
}
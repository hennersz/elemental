{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "controlPlane") {
    elemental.home.program.dev.git = {
      enable = true;

      userEmail = "henry.mortimer@control-plane.io";
      gpgKey = "0xBB7595459BC43FAC";
      signByDefault = true;
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
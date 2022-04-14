{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "controlPlane") {
    elemental.home.program.dev.git = {
      enable = true;

      userEmail = "henry.mortimer@control-plane.io";
      gpgKey = "0x0DE5BA892DE1EA3A";
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
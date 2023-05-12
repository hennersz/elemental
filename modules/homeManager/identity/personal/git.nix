{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "personal") {
    elemental.home.program.dev.git = {
      enable = true;

      userEmail = "henry@morti.net";
      gpgKey = "0xE80F01751AE0A7CE";
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
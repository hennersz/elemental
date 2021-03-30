{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "personal") {
    elemental.home.program.credentials.gpg = {
      enable = true;
      settings.default-key = "E80F01751AE0A7CE";
    };
  };
}
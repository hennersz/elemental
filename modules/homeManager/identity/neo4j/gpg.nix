{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "neo4j") {
    elemental.home.program.credentials.gpg = {
      enable = true;
      settings.default-key = "486EBCAEA5918639CCD6858FE80F01751AE0A7CE";
    };

    services = {
      gpg-agent.sshKeys = [ "A705C1DB38B7366F54588E4FF727024F45E89F0E" ];
    };
  };
}

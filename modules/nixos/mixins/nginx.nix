{ config, pkgs, ... }:
{
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      appendHttpConfig = ''
        access_log syslog:server=unix:/dev/log combined;
      '';
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

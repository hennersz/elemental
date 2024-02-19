{ config, pkgs, ... }:
{
  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.appendHttpConfig = ''
    access_log syslog:server=unix:/dev/log combined;
  '';
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

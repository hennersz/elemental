{ config, pkgs, ... }:
{
  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

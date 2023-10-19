{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    unstable.localsend
  ];

  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];
}

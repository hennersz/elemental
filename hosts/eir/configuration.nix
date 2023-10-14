{ config, inputs, ... }:
let
  hostname = "eir";
  ip = "192.168.1.2";
in
{
  imports = with inputs.self.nixosModules.modules; [
    ./hardware-configuration.nix
    users-henry
    mixins-common
    mixins-selfupdate
    mixins-vpn
    mixins-metrics-server
    mixins-dashboard-server
    mixins-logging-server
    mixins-pihole
    mixins-nginx
  ];

  documentation.man.generateCaches = false;

  system.stateVersion = "22.11";

  elemental.domainName = "eir.lan.morti.net";

  mixins.selfupdate = {
    inherit hostname;
    enable = true;
  };

  networking = {
    inherit hostname;
    networkmanager.enable = true;
    defaultGateway = {
      address = "192.168.1.1";
      interface = "end0";
    };
    nameservers = [
      "127.0.0.1"
      "9.9.9.9"
    ];
    interfaces.end0 = {
      name = "end0";
      ipv4.addresses = [
        {
          address = ip;
          prefixLength = 24;
        }
      ];
    };
  };

  services.openssh.enable = true;
  elemental.pi-hole.interfaces = [ "end0" "tailscale0" ];
  elemental.pi-hole.domain = config.networking.hostName;
  elemental.pi-hole.hostIP = ip;
}

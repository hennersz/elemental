{ config, inputs, ... }:
let
  hostName = "eir";
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
    inherit hostName;
    enable = true;
  };

  networking = {
    inherit hostName;
    defaultGateway = {
      address = "192.168.1.1";
      interface = "end0";
    };
    networkmanager.enable = true;
    networkmanager.insertNameservers = [
      "127.0.0.1"
      "100.100.100.100"
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
  elemental.pi-hole = {
    interfaces = [ "end0" "tailscale0" ];
    domain = config.networking.hostName;
    hostIP = ip;
    revServers = [
      {
        localNetworkCIDR = "192.168.1.0/24";
        dnsServer = "192.168.1.1";
        localDomain = "lan.morti.net";
      }
      {
        localNetworkCIDR = "100.64.0.0/10";
        dnsServer = "100.100.100.100";
        localDomain = "koi-boa.ts.net";
      }
    ];
    cnames = [
      {
        domain = "grafana.morti.net";
        target = "pi.hole";
      }
      {
        domain = "pihole.morti.net";
        target = "pi.hole";
      }
      {
        domain = "eir.lan.morti.net";
        target = "pi.hole";
      }
    ];
  };

  elemental.grafana.domain = "grafana.morti.net";
}

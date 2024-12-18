{ config, pkgs, inputs, ... }:
let
  hostName = "eir";
  ip = "192.168.1.2";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];
  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = false;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # A lot GUI programs need this, nearly all wayland applications
      "cma=128M"
    ];
  };

  hardware.enableRedistributableFirmware = true;

  elemental.domainName = "eir.lan.morti.net";
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/nixos-store";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/var/lib/app-data" = {
      device = "/dev/disk/by-label/app-data";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/tmp" = {
      device = "/dev/disk/by-label/temp";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
    };
  };

  networking = {
    defaultGateway = {
      address = "192.168.1.1";
      interface = "end0";
    };
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

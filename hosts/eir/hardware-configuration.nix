{ config, pkgs, inputs, ...}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
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

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  fileSystems = {
    "/nix" = {
      device = "/dev/disk/by-label/nixos-store";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  fileSystems = {
    "/var/lib/app-data" = {
      device = "/dev/disk/by-label/app-data";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  fileSystems = {
    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
}
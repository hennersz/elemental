{ config, pkgs, lib, ... }:
{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    udev.packages = with pkgs; [ gnome-settings-daemon ];
  };
  environment.systemPackages = [
    pkgs.gnomeExtensions.tailscale-qs
  ];
}

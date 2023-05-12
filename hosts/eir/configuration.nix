{ config, pkgs, inputs, lib,  ...}:
let
  hostname = "eir";
in
{
  imports = with inputs.self.nixosModules.modules; [
    ./hardware-configuration.nix
    users-henry
    mixins-common
    mixins-selfupdate
    mixins-vpn
    mixins-metrics-server
  ];

  documentation.man.generateCaches = false;

  system.stateVersion = "22.11";

  elemental.domainName = "eir.lan.morti.net";

  mixins.selfupdate = {
    enable = true;
    hostname = hostname;
  };

  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
    };
  };

  services.openssh.enable = true;
}
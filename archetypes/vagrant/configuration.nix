{ pkgs, lib, ... }:
let
  modules = import ../../modules/nixos { inherit lib; };
in
{
  imports = with modules; [
    mixins-common
    mixins-vpn
    users-vagrant
  ];

  system.stateVersion = "22.11";

  # Use the GRUB 2 boot loader.
  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    # remove the fsck that runs at startup. It will always fail to run, stopping
    # your boot until you press *.
    initrd.checkJournalingFS = false;
  };

  # Services to enable:
  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      extraConfig = ''
        PubkeyAcceptedKeyTypes +ssh-rsa
      '';
    };

    # Enable DBus
    dbus.enable = true;

    # Replace ntpd by timesyncd
    timesyncd.enable = true;
  };

  # Packages for Vagrant
  environment.systemPackages = with pkgs; [
    findutils
    gnumake
    iputils
    jq
    nettools
    netcat
    nfs-utils
    rsync
    vim
    git
  ];

  security.sudo.extraConfig =
    ''
      Defaults:root,%wheel env_keep+=LOCALE_ARCHIVE
      Defaults:root,%wheel env_keep+=NIX_PATH
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults lecture = never
      root   ALL=(ALL) SETENV: ALL
      %wheel ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
    '';

}

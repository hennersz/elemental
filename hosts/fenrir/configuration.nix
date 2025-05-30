{ pkgs, inputs, ... }:
{
  imports = with inputs.self.nixosModules.modules; [
    ./hardware-configuration.nix
    ./grub.nix
    mixins-common
    mixins-vpn
    mixins-audio
    mixins-gnome
    mixins-libvirt
    mixins-containers
    mixins-localsend
    users-henry
  ];

  networking.hostName = "fenrir"; # Define your hostname.

  programs.dconf.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    firefox
    git
    gnupg
    pinentry-curses
  ];

  fonts.fonts = with pkgs; [
    pkgs.nerd-fonts.space-mono
  ];

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };
  system.stateVersion = "23.11";

  services.ntp.enable = true;
}

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
    users-builder
  ];

  networking.hostName = "hel"; # Define your hostname.

  programs.dconf.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    firefox
    alacritty
    git
    gnupg
    pinentry-curses
  ];

  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };
  system.stateVersion = "22.05";

  services.openssh.enable = true;
}

{ config, pkgs, inputs, ... }:
{
  imports = with inputs.self.nixosModules.modules; [
    ./hardware-configuration.nix
    ./grub.nix
    mixins-common
    mixins-vpn
    mixins-audio
    mixins-gnome
    users-henry
  ];

  networking.hostName = "hel"; # Define your hostname.

  programs.dconf.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim 
    firefox
    alacritty
    vscode
    git
    gnupg
    pinentry-curses
    pass
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
}

{ config, lib, pkgs, ... }:
with lib;
{
  config = lib.mkIf (config.elemental.machine == "hel") {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/home/henry/Credentials/passwords";
      };
    };

    home.packages = with pkgs; [
      spotify
      slack
      vagrant
      firefox
      alacritty
      vlc
      neofetch
    ];
    gtk = {
      enable = true;
      theme = {
        name = "Nordic";
        package = pkgs.nordic;
      };
      iconTheme = {
        name = "Tela";
        package = pkgs.tela-icon-theme;
      };
    };
  };
} 
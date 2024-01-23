{ config, lib, pkgs, ... }:
with lib;
{
  config = lib.mkIf (config.elemental.machine == "fenrir") {
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
      alacritty
      vlc
      neofetch
      chromium
      firefox-devedition
      jdk
      jetbrains.idea-community
      discord
      unstable.localsend
      vscode
    ];

    home.sessionVariables = {
      JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
    };

    services.gpg-agent.pinentryFlavor = "curses";

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

{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "nixos-workstation") {
    elemental.home.program = {
      editor.vscode.enable = true;
    };

    # Environment
    home.sessionVariables = {
      EDITOR = "code --wait";
      JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
    };

    home.packages = with pkgs; [
      spotify
      slack
      vagrant
      vlc
      neofetch
      chromium
      firefox-devedition
      jdk
      jetbrains.idea-community
      discord
      localsend
      vscode
      wl-clipboard
      gnomeExtensions.tailscale-qs
      zoom-us
    ];

    services.gpg-agent.pinentryPackage = pkgs.pinentry-curses;

    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";

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

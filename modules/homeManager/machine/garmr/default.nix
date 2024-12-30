{ config, lib, pkgs, ... }:
with lib;
{
  config = lib.mkIf (config.elemental.machine == "garmr") {
    home.sessionVariables = {
      ELEMENTAL_SOURCE_DIR = "/home/henry/.config/nixpkgs";
    };

    elemental.home.program.shell.fish.extraAliases = {
      docker = "sudo docker";
      kind = "sudo kind";
      docker-compose = "sudo docker-compose";
    };

    home.packages = with pkgs; [
      neofetch
      pkgs.nerd-fonts.space-mono
      podman
      dive
      kind
      docker-compose
    ];

    fonts.fontconfig.enable = true;

    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/home/henry/Credentials/passwords";
      };
    };

    services.gpg-agent.extraConfig = ''
      pinentry-program /usr/bin/pinentry-gnome3
    '';
  };
}

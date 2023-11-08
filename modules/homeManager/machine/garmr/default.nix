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

    elemental.home.program.shell.fish.gpgSSHAuthSock = true;

    home.packages = with pkgs; [
      vagrant
      neofetch
      nerdfonts
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
  };
}

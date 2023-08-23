{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.user == "vagrant") {
    elemental.home = {
      program = {
        shell.fish.enable = true;

        dev = {
          git = {
            enable = true;
            userName = "Henry Mortimer";
            extraConfig = {
              pull.rebase = true;
            };
          };
          bat.enable = true;
        };
      };
    };

    home = {
      username = "vagrant";
      homeDirectory = "/home/vagrant";
      packages = with pkgs; [
        # Rust CLI Tools
        bat
        exa

        # Utils
        asciinema
        neovim
        jq
        yq-go
        tldr

        # Common CLI tools
        gnutar
        coreutils-full
        direnv
        git
        unzip
        whois
        dogdns

        # Overview
        htop
      ];
    };
  };
}

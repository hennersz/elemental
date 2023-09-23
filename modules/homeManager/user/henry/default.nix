{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.user == "henry") {
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
        editor.nvim.enable = true;
      };
    };

    home = {
      username = "henry";
      homeDirectory = "/home/henry";
      packages = with pkgs; [
        # Rust CLI Tools
        bat
        exa

        # Utils
        asciinema
        jq
        yq-go
        tldr

        # Common CLI tools
        gnutar
        gnumake
        clang
        coreutils-full
        direnv
        git
        unzip
        whois
        dogdns

        # Overview
        btop
      ];
    };
  };
}

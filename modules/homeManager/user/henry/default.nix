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
      };
    };

    home = {
      username = "henry";
      homeDirectory = lib.mkDefault "/home/henry";
      packages = with pkgs; [
        # Rust CLI Tools
        bat
        eza

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
        btop

        dive
        skopeo

        go
        golangci-lint
        google-cloud-sdk
      ];

      sessionVariables = {
        BULLETTRAIN_CONTEXT_DEFAULT_USER = "henry";
      };
    };
  };
}

{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.user == "ubuntu") {
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
      username = "ubuntu";
      homeDirectory = lib.mkDefault "/home/ubuntu";
      packages = with pkgs; [
        # Rust CLI Tools
        bat
        eza

        # Utils
        asciinema
        jq
        yq
        tldr

        # Common CLI tools
        gnutar
        coreutils-full
        direnv
        git
        unzip
        whois
        doggo

        # Overview
        btop

        dive
        skopeo
        k9s

        go
        golangci-lint
        google-cloud-sdk
      ];

      sessionVariables = {
        BULLETTRAIN_IS_SSH_CLIENT = "true";
        BULLETTRAIN_CONTEXT_DEFAULT_USER = "ubuntu";
      };
    };
  };
}

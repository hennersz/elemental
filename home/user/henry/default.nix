{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.user == "henry") {
    elemental.home = {
      program = {
        shell.fish.enable = true;
        networking.nmap.enable = true;

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

    nixpkgs.overlays = [ (self: super: {
      kubernetes = super.kubernetes.override {
        components = [];
      };
    } ) ];

    # Install packages
    home.packages = with pkgs; [
      # Rust CLI Tools
      bat
      exa

      # Utils
      neovim
      jq
      yq
      tldr

      # Common CLI tools
      gnupg
      gnutar

      # Development
      clang
      clangStdenv
      direnv
      dive
      git
      gnumake
      go
      golangci-lint
      kubernetes-helm
      kubectl
      nodejs
      python38Full
      python38Packages.poetry
      ruby_2_7
      rustup
      skopeo
      vagrant
      yarn

      # Files and networking
      unzip
      whois

      # Media
      youtube-dl
      imagemagick
      powerline-fonts
      nerdfonts

      # Overview
      htop
      neofetch

      # Jokes
      cowsay
      fortune
      figlet
      lolcat
      nms
    ];

    home.sessionVariables = {
      CC = "clang";
      CXX = "clang++";
    };
  };
}

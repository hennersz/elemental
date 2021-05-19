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
      gnutar
      coreutils-full

      # Development
      clang
      clangStdenv
      direnv
      dive
      git
      gnumake
      go
      golangci-lint
      k9s
      kind
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
    
    programs.password-store.package = pkgs.pass.withExtensions (exts: [ exts.pass-import ]);

    home.sessionVariables = {
      CC = "clang";
      CXX = "clang++";
    };
  };
}

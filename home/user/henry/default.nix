{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> { config = { allowUnfree = true; }; };
in
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
      asciinema
      grpcurl
      neovim
      jq
      yq
      paperkey
      tldr
      vault

      # Communication
      # keybase

      # Cloud CLI Tools
      awscli2
      unstable.nodePackages.aws-cdk
      eksctl
      google-cloud-sdk

      # Common CLI tools
      gnutar
      coreutils-full

      # Development
      # adoptopenjdk-hotspot-bin-17
      jdk11
      ansible_2_12
      ansible-lint
      clang
      clangStdenv
      direnv
      dive
      ghc
      git
      gnumake
      go
      gradle
      # golangci-lint
      istioctl
      k9s
      kind
      kubernetes-helm
      kubectl
      nodejs-16_x
      open-policy-agent
      operator-sdk
      packer
      python39
      python39Packages.poetry
      ruby_2_7
      rustup
      skopeo
      terraform
      yarn

      # Files and networking
      unzip
      whois
      dogdns

      # Media
      nerdfonts

      # Overview
      htop
      neofetch

      #yubikey
      yubikey-personalization
      yubikey-manager
    ];
    
    programs.password-store.package = pkgs.pass.withExtensions (exts: [ exts.pass-import ]);

    home.sessionVariables = {
      CC = "clang";
      CXX = "clang++";
      JAVA_HOME = pkgs.jdk11;
      TERRAFORM_TEMPLATE_DIR = "$HOME/Projects/Infrastructure/Terraform/templates";
    };

    home.activation = {
      linkJava = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ln -sTf $VERBOSE_ARG \
          ${pkgs.jdk11} \
          $HOME/.java
      '';
    };
  };

}

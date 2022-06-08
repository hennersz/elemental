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
      grpcurl
      neovim
      jq
      yq
      tldr
      vault

      # Communication
      keybase

      # Cloud CLI Tools
      awscli2
      eksctl
      google-cloud-sdk

      # Common CLI tools
      gnutar
      coreutils-full

      # Development
      adoptopenjdk-hotspot-bin-16
      ansible_2_12
      ansible-lint
      clang
      clangStdenv
      direnv
      dive
      git
      gnumake
      go
      # golangci-lint
      istioctl
      k9s
      kind
      kubernetes-helm
      kubectl
      nodejs-16_x
      operator-sdk
      packer
      python39
      python39Packages.poetry
      ruby_2_7
      rustup
      skopeo
      terraform
      vagrant
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
      JAVA_HOME = pkgs.adoptopenjdk-hotspot-bin-16;
    };

    home.activation = {
      linkJava = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ln -sTf $VERBOSE_ARG \
          ${pkgs.adoptopenjdk-hotspot-bin-16} \
          $HOME/.java
      '';
    };
  };

}

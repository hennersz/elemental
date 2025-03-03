{ pkgs, lib, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    gnupg
    vscode
    alacritty
    gh
    devpod
  ];


  nix = {
    enable = true;
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 16;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 128 * 1024;
            memorySize = 16 * 1024;
          };
          cores = 8;
        };
      };
    };

    # This line is a prerequisite
    settings = {
      trusted-users = [ "@admin" ];
      experimental-features = "nix-command flakes";
    };
  };
  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
    interval = {
      Hour = 5;
      Minute = 0;
    };
  };

  users.knownUsers = [ "henry" ];

  users.users.henry = {
    home = "/Users/henry";
    shell = pkgs.fish;
    uid = 502;
  };

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    #cleanup = "zap";
    global = {
      brewfile = true;
    };
    taps = [ "homebrew/bundle" "homebrew/homebrew-services" ];
    brews = [
      "pinentry-mac"
      "socket_vmnet"
      "snyk-cli"
    ];
    casks = [
      "google-drive"
      "scroll-reverser"
      "logseq"
      "devpod"
      "cursor"
      "1password"
      "burp-suite"
      "ghidra"
      "temurin"
      "spotify"
    ];
    masApps = { };
  };

  launchd.daemons.socket_vmnet = {
    script = ''
      /opt/homebrew/opt/socket_vmnet/bin/socket_vmnet --vmnet-gateway=192.168.105.1 --vmnet-dhcp-end=192.168.105.100 /opt/homebrew/var/run/socket_vmnet
    '';
    serviceConfig = {
      StandardOutPath = "/opt/homebrew/var/log/socket_vmnet/stdout";
      StandardErrorPath = "/opt/homebrew/var/log/socket_vmnet/stderr";
    };
  };

  fonts = {
    packages = [
      pkgs.nerd-fonts.space-mono
    ];
  };

  system.defaults.NSGlobalDomain = {
    ApplePressAndHoldEnabled = false;
    AppleShowAllFiles = true;
    NSNavPanelExpandedStateForSaveMode = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}

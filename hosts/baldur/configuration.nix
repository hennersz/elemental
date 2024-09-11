{ pkgs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    gnupg
    vscode
    alacritty
    gh
    localsend
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

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
    taps = [ "homebrew/bundle" ];
    brews = [ 
      "pinentry-mac"
    ];
    casks = [
      "google-drive"
      "scroll-reverser"
    ];
    masApps = { };
  };

  fonts = {
    packages = [
      pkgs.nerdfonts
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

{ config, lib, ... }:
with lib;
let
  cfg = config.elemental.home.program.dev.git;
in
{
  options.elemental.home.program.dev.git = {
    enable = lib.mkEnableOption "Enable git";

    userEmail = lib.mkOption {
      type = types.lines;
      description = "The git config email";
      default = "";
    };

    userName = lib.mkOption {
      type = types.lines;
      description = "The git config name";
      default = "";
    };

    gpgKey = lib.mkOption {
      type = types.lines;
      description = "The gpg-signing key";
      default = "";
    };

    signByDefault = lib.mkOption {
      type = types.bool;
      description = "Whether to gpg sign by default";
      default = false;
    };

    extraConfig = lib.mkOption {
      type = types.attrs;
      description = "extra git config";
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      inherit (cfg) userEmail userName;
      enable = true;
      signing.key = cfg.gpgKey;
      signing.signByDefault = cfg.signByDefault;
      delta.enable = true; # Use Delta for diff viewing
      extraConfig = {
        # Pull behaviour
        pull.rebase = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        url = {
          "git@github.com:" = {
            insteadOf = "https://github.com/";
          };
        };
      } // cfg.extraConfig;
      # Aliases
      aliases = {
        "s" = "status";
        "co" = "checkout";
        "br" = "branch";
        # Commits, additions, and modifications
        "cm" = "commit -m";
        "aa" = "add .";
        "rh" = "reset --hard";
        # Logging
        "lgo" = "log --oneline --graph";
        "lo" = "log --oneline";
        "ln" = "log -n"; # follow with a number to show n logs
        "lon" = "log --oneline -n"; # follow with a number to show n logs
      };
    };
  };
}

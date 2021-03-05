{ config, lib, pkgs, ... }:
with
lib;
let
  cfg = config.elemental.home.program.shell.fish;
  promptSource = pkgs.fetchFromGitHub {
    owner = "kobanyan";
    repo = "bullet-train-fish-theme";
    rev = "4fe9235eac27da257d543821afb0233537d8650a";
    sha256 = "17g1h88j2zkwnjadxv8k162p2z66wpdfk362dp4y9f44i3sgczrl";
  };


in
{
  options.elemental.home.program.shell.fish = {
    enable = mkEnableOption "Enable the fish shell";

    preShellInit = mkOption {
      type = types.lines;
      default = "";
      description = "Prepend to the shell init script";
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      shellAbbrs = {
        g = "git";
        k = "kubectl";
      };

      shellAliases = {
        cat = "bat";
        ls = "exa";
        l = "exa -l";
        ll = "exa -laguUmh";
        lt = "exa -lRT";
      };

      promptInit = builtins.readFile "${promptSource}/fish_prompt.fish";

      shellInit = cfg.preShellInit + ''
        bass source $HOME/.nix-profile/etc/profile.d/nix.sh
        direnv hook fish | source
      '';

      plugins = [
        {
          name = "bass";
          src = pkgs.fetchFromGitHub {
            owner = "edc";
            repo = "bass";
            rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
            sha256 = "0mb01y1d0g8ilsr5m8a71j6xmqlyhf8w4xjf00wkk8k41cz3ypky";
          };
        }
      ];

    };

    xdg.configFile = (
      mapAttrs' 
        (name: _: 
          nameValuePair 
            ("fish/conf.d/${name}")
            { source = (./config + "/${name}"); executable = false; }
        ) 
        (builtins.readDir ./config)
    ) // (
      mapAttrs' 
        (name: _: 
          nameValuePair 
            ("fish/functions/${name}")
            { source = (./functions + "/${name}"); executable = false; }
        ) 
        (builtins.readDir ./functions)
    );

    home.activation = { 
      linkFish = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD sudo ln -sf $VERBOSE_ARG \
          ${pkgs.fish}/bin/fish /usr/local/bin/
      '';

      # echoFile = lib.hm.dag.entryAfter ["writeBoundary"] ''
      #   $DRY_RUN_CMD cat $VERBOSE_ARG \
      #     ${builtins.toFile "default.nix" (builtins.readFile ./default.nix)}
      # '';

    };
  };
}

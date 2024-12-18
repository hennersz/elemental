{ config, lib, pkgs, ... }:
with
lib;
let
  cfg = config.elemental.home.program.shell.fish;
  promptSource = pkgs.fetchFromGitHub {
    owner = "hennersz";
    repo = "bullet-train-fish-theme";
    rev = "f8f09064f84df4c5dc274b2d5c8ac024106ecb52";
    sha256 = "1fsvf9h7mzamhxxflk2dp6lvgsj5xhd5scpvygjjhkdqfj3ddsb5";
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

    extraAliases = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra aliases for fish";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      direnv
      python3Full
      eza
      bat
    ];
    programs.fish = {
      enable = true;

      shellAbbrs = {
        g = "git";
        k = "kubectl";
      };

      shellAliases = mkMerge [{
        cat = "bat";
        dig = "dog";
        ls = "eza";
        l = "eza -l";
        ll = "eza -laaguUmh";
        lt = "eza -lRT";
        top = "btop";
      }
        cfg.extraAliases];

      interactiveShellInit = builtins.readFile "${promptSource}/functions/fish_prompt.fish";

      shellInit = cfg.preShellInit + ''
        set -g fish_greeting
        direnv hook fish | source
        set fish_complete_path $HOME/.nix-profile/etc/fish/completions /nix/var/nix/profiles/default/etc/fish/completions $HOME/.nix-profile/share/fish/vendor_completions.d /nix/var/nix/profiles/default/share/fish/vendor_completions.d  $fish_complete_path
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
            "fish/conf.d/${name}"
            { source = ./config + "/${name}"; executable = false; }
        )
        (builtins.readDir ./config)
    ) // (
      mapAttrs'
        (name: _:
          nameValuePair
            "fish/functions/${name}"
            { source = ./functions + "/${name}"; executable = false; }
        )
        (builtins.readDir ./functions)
    );

    home.emptyActivationPath = false;
    home.activation = {
      linkFish = lib.mkIf (!(lib.strings.hasPrefix "nixos" config.elemental.role)) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD bash -c 'if [[ "$(readlink -f /usr/local/bin/fish)" != "${pkgs.fish}/bin/fish" ]]; then
          sudo ln -sf $VERBOSE_ARG ${pkgs.fish}/bin/fish /usr/local/bin/fish
        fi'
      '');
    };
  };
}

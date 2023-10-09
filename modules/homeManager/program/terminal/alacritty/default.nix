{ lib, pkgs, config, ... }:
with
lib;
let
  cfg = config.elemental.home.program.terminal.alacritty;
  themes = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "e4464d5ed853d510db5d93b5199d4569d34669d8";
    sha256 = "C0q4eBtxpER2ellG0Os/BTL3MDaq4rao3Yh+ytnR1X4=";
  };
in
{
  options.elemental.home.program.terminal.alacritty = {
    enable = mkEnableOption "Enable the alacritty terminal";

    settingOverrides = mkOption {
      type = types.attrs;
      default = { };
      description = "Override the elemental default config";
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = lib.attrsets.recursiveUpdate
        ({
          env = {
            "TERM" = "xterm-256color";
          };

          import = [
            "${themes}/themes/solarized_light.yaml"
          ];

          window = {
            padding.x = 0;
            padding.y = 10;
            decorations = "full";
            opacity = 1;
          };

          font = {
            size = 14.0;

            normal.family = "SpaceMono Nerd Font";
            bold.family = "SpaceMono Nerd Font";
            italic.family = "SpaceMono Nerd Font";
          };

          cursor.style = "Underline";
        })
        cfg.settingOverrides;
    };
  };
}
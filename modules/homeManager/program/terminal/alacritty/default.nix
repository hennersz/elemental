{ lib, pkgs, config, ... }:
with
lib;
let
  cfg = config.elemental.home.program.terminal.alacritty;
  tomlFormat = pkgs.formats.toml { };
  configFileName = "alacritty.toml";
  themes = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "f03686afad05274f5fbd2507f85f95b1a6542df4";
    sha256 = "457kKE3I4zGf1EKkEoyZu0Fa/1O3yiryzHVEw2rNZt8=";
  };

  defaultSettings = {
    env = {
      "TERM" = "xterm-256color";
      "LC_ALL" = "";
    };

    import = [
      "${themes}/themes/solarized_light.toml"
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
  };
in
{
  options.elemental.home.program.terminal.alacritty = {
    enable = mkEnableOption "Enable the alacritty terminal";

    settingsOverrides = mkOption {
      type = types.attrs;
      default = { };
      description = "Override the elemental default config";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (config.elemental.role == "nixos-workstation") [ pkgs.unstable.alacritty ];

    xdg.configFile."alacritty/${configFileName}" = {
      source =
        (tomlFormat.generate configFileName (lib.attrsets.recursiveUpdate defaultSettings cfg.settingsOverrides)).overrideAttrs
          (finalAttrs: prevAttrs: {
            buildCommand = lib.concatStringsSep "\n" [
              prevAttrs.buildCommand
              # TODO: why is this needed? Is there a better way to retain escape sequences?
              "substituteInPlace $out --replace '\\\\' '\\'"
            ];
          });
    };
  };
}

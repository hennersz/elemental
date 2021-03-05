{ config, lib, ...}:
with lib;
let
  cfg = config.elemental.home.program.dev.bat;
in
{
  options.elemental.home.program.dev.bat = {
    enable = mkEnableOption "Enable bat";
  };

  config = mkIf cfg.enable {
    xdg.configFile."bat/config".source = ./bat.conf;
  };
}
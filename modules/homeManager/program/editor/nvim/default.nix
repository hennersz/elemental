{ config, lib, ...}:
with lib;
let
  cfg = config.elemental.home.program.editor.nvim;
in
{
  options.elemental.home.program.editor.nvim = {
    enable = mkEnableOption "Enable nvim";
  };

  config = mkIf cfg.enable {
    xdg.configFile."nvim/lua/" = {
      source = ./config/lua;
      recursive = true;
    };
    xdg.configFile."nvim/init.lua" = {
      source = ./config/init.lua;
    };
    xdg.configFile."nvim/stylua.toml" = {
      source = ./config/stylua.toml;
    };
    xdg.configFile."nvim/.neoconf.json" = {
      source = ./config/.neoconf.json;
    };
  };
}
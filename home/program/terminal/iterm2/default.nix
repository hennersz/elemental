{ config, lib, ... }:
with lib;
let
  cfg = config.elemental.home.program.terminal.iterm2;
in
{
  options.elemental.home.program.terminal.iterm2 = {
    enable = mkEnableOption "Enable iterm2";
  };

  config = mkIf cfg.enable {
    home.file.itermConfig = {
      source = ./com.googlecode.iterm2.plist;
      target = ".config/iterm2/com.googlecode.iterm2.plist.source";
      onChange = "cp ~/.config/iterm2/com.googlecode.iterm2.plist.source ~/.config/iterm2/com.googlecode.iterm2.plist";
    };

    xdg.configFile = {
      "fish/functions/syncItermConfig.fish" = {
        source = ./syncItermConfig.fish;
        executable = false;
      };
    };
  };

}

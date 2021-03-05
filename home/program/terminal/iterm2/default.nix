{ config, lib, ...}:
with lib;
let 
  cfg = config.elemental.home.program.terminal.iterm2;
in
{
  options.elemental.home.program.terminal.iterm2 = {
    enable = mkEnableOption "Enable iterm2";
  };

  config = mkIf cfg.enable {
    home.activation = { 
      linkIterm2 = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.xdg.configHome}/iterm2 && \
          ln -sf $VERBOSE_ARG \
          ${builtins.toString ./com.googlecode.iterm2.plist} \
          ${config.xdg.configHome}/iterm2/com.googlecode.iterm2.plist
      '';
    };
  };

}
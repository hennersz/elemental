{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.mixins.selfupdate;
in
{

  options.mixins.selfupdate = {
    enable = mkEnableOption "self update service";
    hostname = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.timers."update" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "update.service";
      };
    };

    systemd.services."update" = {
      stopIfChanged = false;
      restartIfChanged = false;
      script = ''
        set -eu
        cd /etc/nixos
        if update=$(nix flake update 2>&1); then
          count=$(echo "$update" | grep -c Updated || true)
          if [ "$count" != "0" ]; then
            nixos-rebuild switch --flake '/etc/nixos#${cfg.hostname}'
          fi
        else 
          echo "$update"
          exit 1
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      path = with pkgs; [ coreutils gnugrep nix nixos-rebuild git ];
    };
  };
}

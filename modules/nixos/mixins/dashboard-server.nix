{ config, pkgs, lib, ... }:
let
  cfg = config.elemental.grafana;
in
{
  options.elemental.grafana = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "grafana";
    };

    secretKeyFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/app-data/grafana/secret_key";
      description = ''
        Path to a file containing Grafana's `secret_key`. The file is read at
        runtime via Grafana's file provider and must not live in the Nix store.

        Created automatically on first start if missing. If Grafana already has a
        database, keep the same `secret_key` across rebuilds or sessions will be
        invalidated.
      '';
    };
  };

  config = let
    grafanaPort = 2342;
    grafanaDataDir = "/var/lib/app-data/grafana";
  in {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          inherit (cfg) domain;
          root_url = "http://${cfg.domain}";
          http_port = grafanaPort;
          http_addr = "0.0.0.0";
        };
        security.secret_key = "$__file{${cfg.secretKeyFile}}";
      };
      dataDir = grafanaDataDir;
    };

    users.users.grafana.createHome = lib.mkForce false;

    services.nginx.virtualHosts.${cfg.domain} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString grafanaPort}";
        proxyWebsockets = true;
      };
    };

    # grafana.service is sandboxed (SystemCallFilter blocks chown); setup runs here instead.
    systemd.services.grafana-prepare = {
      description = "Prepare Grafana data directory and secret key";
      before = [ "grafana.service" ];
      after = [
        "local-fs.target"
        "elemental-app-data-prepare.service"
      ];
      requiredBy = [ "grafana.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.coreutils}/bin/mkdir -p "${grafanaDataDir}"
        ${pkgs.coreutils}/bin/chown grafana:grafana "${grafanaDataDir}"
        ${pkgs.coreutils}/bin/chmod 0750 "${grafanaDataDir}"
        if [ ! -s "${cfg.secretKeyFile}" ]; then
          ${pkgs.openssl}/bin/openssl rand -hex 32 > "${cfg.secretKeyFile}"
        fi
        ${pkgs.coreutils}/bin/chmod 600 "${cfg.secretKeyFile}"
        ${pkgs.coreutils}/bin/chown grafana:grafana "${cfg.secretKeyFile}"
      '';
    };

    systemd.services.grafana = {
      after = [
        "grafana-prepare.service"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Restart = lib.mkDefault "on-failure";
        TimeoutStartSec = lib.mkDefault "120";
      };
    };
  };
}

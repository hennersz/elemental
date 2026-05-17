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
        Path to a host-local file containing Grafana's `secret_key`.
        The file is read at runtime via Grafana's file provider and must not
        live in the Nix store.

        On first deploy, create it before switching. If Grafana already has a
        database, reuse the same secret_key you used previously:

        ```
        sudo install -d -m 0750 -o grafana -g grafana /var/lib/app-data/grafana
        sudo openssl rand -hex 32 | sudo tee /var/lib/app-data/grafana/secret_key
        sudo chmod 600 /var/lib/app-data/grafana/secret_key
        sudo chown grafana:grafana /var/lib/app-data/grafana/secret_key
        ```
      '';
    };
  };

  config = {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          inherit (cfg) domain;
          root_url = "http://${cfg.domain}";
        };
        security.secret_key = "$__file{${cfg.secretKeyFile}}";
      };
      port = 2342;
      addr = "0.0.0.0";
      dataDir = "/var/lib/app-data/grafana";
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        proxyWebsockets = true;
      };
    };
    networking.firewall.allowedTCPPorts = [ 2342 ];

    systemd.services.grafana.preStart = lib.mkAfter ''
      if [ ! -s "${cfg.secretKeyFile}" ]; then
        ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "${cfg.secretKeyFile}")"
        ${pkgs.openssl}/bin/openssl rand -hex 32 > "${cfg.secretKeyFile}"
        ${pkgs.coreutils}/bin/chmod 600 "${cfg.secretKeyFile}"
        ${pkgs.coreutils}/bin/chown grafana:grafana "${cfg.secretKeyFile}"
      fi
    '';
  };
}

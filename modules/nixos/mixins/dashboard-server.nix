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
  };

  config = {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          inherit (cfg) domain;
          root_url = "http://${cfg.domain}";
        };
      };
      port = 2342;
      addr = "127.0.0.1";
      dataDir = "/var/lib/app-data/grafana";
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        proxyWebsockets = true;
      };
    };
  };
}

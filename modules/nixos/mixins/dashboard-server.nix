{ config, pkgs, ... }:
{
  # grafana configuration
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = config.elemental.domainName;
        root_url = "http://${config.elemental.domainName}/grafana";
        serve_from_sub_path = true;
      };
    };
    port = 2342;
    addr = "127.0.0.1";
    dataDir = "/var/lib/app-data/grafana";
  };

  services.nginx.virtualHosts.${config.elemental.domainName} = {
    locations."/grafana/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
    };
  };
}

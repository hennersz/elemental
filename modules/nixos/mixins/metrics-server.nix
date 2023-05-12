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
    dataDir = "/var/lib/metrics-data/grafana";
  };

  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx.virtualHosts.${config.elemental.domainName} = {
    locations."/grafana/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        proxyWebsockets = true;
    };
  };
  
  services.prometheus = {
    enable = true;
    port = 9001;
    stateDir = "metrics-data/prometheus";
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "self";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };
}
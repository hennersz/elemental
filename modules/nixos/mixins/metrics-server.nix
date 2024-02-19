{ config, pkgs, ... }:
{
  services.prometheus = {
    enable = true;
    port = 9001;
    stateDir = "app-data/prometheus";
    extraFlags = [ "--storage.tsdb.retention.time=90d" ];
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

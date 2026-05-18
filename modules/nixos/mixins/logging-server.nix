{ config, pkgs, lib, ... }:
let
  lokiDataDir = "/var/lib/app-data/loki";
in
{
  services.loki = {
    enable = true;
    dataDir = lokiDataDir;
    configuration = {
      server.http_listen_port = 3030;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
      };

      schema_config = {
        configs = [{
          from = "2022-06-06";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };

      storage_config = {
        boltdb_shipper = {
          active_index_directory = "${lokiDataDir}/boltdb-shipper-active";
          cache_location = "${lokiDataDir}/boltdb-shipper-cache";
          cache_ttl = "24h";
        };

        filesystem = {
          directory = "${lokiDataDir}/chunks";
        };
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        allow_structured_metadata = false;
        volume_enabled = true;
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };

      compactor = {
        working_directory = lokiDataDir;
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };
    };
    # user, group, dataDir, extraFlags, (configFile)
  };

  users.users.loki.createHome = lib.mkForce false;

  systemd.services.loki-prepare = {
    description = "Prepare Loki data directories";
    before = [ "loki.service" ];
    after = [
      "local-fs.target"
      "elemental-app-data-prepare.service"
    ];
    requiredBy = [ "loki.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.coreutils}/bin/mkdir -p "${lokiDataDir}"
      ${pkgs.coreutils}/bin/mkdir -p \
        "${lokiDataDir}/boltdb-shipper-active" \
        "${lokiDataDir}/boltdb-shipper-cache" \
        "${lokiDataDir}/chunks"
      ${pkgs.coreutils}/bin/chown -R loki:loki "${lokiDataDir}"
      ${pkgs.coreutils}/bin/chmod 0750 "${lokiDataDir}"
    '';
  };

  systemd.services.loki.after = lib.mkAfter [ "loki-prepare.service" ];

  # alloy: HTTP listen on port 3031 (8031)
  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:3031"
      "--disable-reporting"
    ];
  };

  environment.etc."alloy/logging.alloy".text = ''
    loki.write "default" {
      endpoint {
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
      }
    }

    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.source.journal "journal" {
      forward_to    = [loki.write.default.receiver]
      relabel_rules = loki.relabel.journal.rules
      max_age       = "12h"
      labels = {
        job  = "systemd-journal",
        host = "${config.networking.hostName}",
      }
    }
  '';
}

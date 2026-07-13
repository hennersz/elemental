{ pkgs, lib, config, ... }:
let
  cfg = config.elemental.pi-hole;

  dnsRevServers =
    lib.concatStringsSep ";" (
      map
        (rs: "true,${rs.localNetworkCIDR},${rs.dnsServer}#53,${rs.localDomain}")
        cfg.revServers
    );

  cnameDnsmasqLines =
    lib.concatStringsSep ";" (
      map (c: "cname=${c.domain},${c.target}") cfg.cnames
    );
in
{
  options.elemental.pi-hole = with lib; {
    image = mkOption {
      type = types.str;
      # Last v5 image was 2024.07.0; 2026.04.x is v6 — see https://docs.pi-hole.net/docker/upgrading/v5-v6/
      default = "pihole/pihole:2026.05.0";
    };

    domain = mkOption {
      type = types.str;
      default = "pi.hole";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
    };

    interfaces = mkOption {
      type = types.listOf types.str;
      default = [ "eth0" ];
    };

    upstreams = mkOption {
      type = types.listOf types.str;
      default = [ "9.9.9.9" "149.112.112.112" ];
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/app-data";
    };

    hostIP = mkOption {
      type = types.str;
    };

    revServers = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
    };

    cnames = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
    };

    shared-memory = mkOption {
      type = types.str;
      default = "256m";
    };
  };

  config =
    let
      piholeDir = "${cfg.dataDir}/pi-hole";
      piholeEnv = {
        TZ = config.time.timeZone;
        FTLCONF_webserver_port = builtins.toString cfg.port;
        FTLCONF_webserver_api_password = "";
        FTLCONF_dns_listeningMode = "ALL";
        FTLCONF_dns_interface = builtins.head cfg.interfaces;
        FTLCONF_dns_upstreams = lib.concatStringsSep ";" cfg.upstreams;
        FTLCONF_dns_reply_host_IPv4 = cfg.hostIP;
      }
      // lib.optionalAttrs (cfg.revServers != [ ]) {
        FTLCONF_dns_revServers = dnsRevServers;
      }
      // lib.optionalAttrs (cfg.cnames != [ ]) {
        FTLCONF_misc_dnsmasq_lines = cnameDnsmasqLines;
      };
    in
    {
      virtualisation.oci-containers.containers.pi-hole = {
        inherit (cfg) image;
        extraOptions = [
          "--network=host"
          "--dns=127.0.0.1"
          "--dns=9.9.9.9"
          "--hostname=${cfg.domain}"
          "--shm-size=${cfg.shared-memory}"
        ];
        environment = piholeEnv;
        volumes = [
          "${cfg.dataDir}/pi-hole/etc:/etc/pihole"
          "${cfg.dataDir}/pi-hole/log:/var/log"
        ];
      };

      systemd.services.pi-hole-prepare = {
        description = "Prepare Pi-hole container volume directories";
        before = [ "podman-pi-hole.service" ];
        after = [
          "local-fs.target"
          "elemental-app-data-prepare.service"
        ];
        requiredBy = [ "podman-pi-hole.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.coreutils}/bin/mkdir -p \
            "${piholeDir}/etc" \
            "${piholeDir}/log/pihole"
          ${pkgs.coreutils}/bin/chown -R root:root "${piholeDir}"
          ${pkgs.coreutils}/bin/chmod -R u=rwX,g=rX,o=rX "${piholeDir}"
        '';
      };

      systemd.services.podman-pi-hole.after = lib.mkAfter [ "pi-hole-prepare.service" ];

      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];

      services.nginx.virtualHosts."${cfg.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };

      environment.etc."alloy/pihole.alloy".text =
        let
          logDir = "${cfg.dataDir}/pi-hole/log";
          host = config.networking.hostName;
        in
        ''
          local.file_match "pihole" {
            path_targets = [
              {
                __address__ = "localhost",
                __path__    = "${logDir}/pihole/FTL.log",
                job         = "pi-hole-FTL",
                host        = "${host}",
              },
              {
                __address__ = "localhost",
                __path__    = "${logDir}/pihole/pihole.log",
                job         = "pi-hole",
                host        = "${host}",
              },
              {
                __address__ = "localhost",
                __path__    = "${logDir}/pihole/pihole_updateGravity.log",
                job         = "pi-hole-update-gravity",
                host        = "${host}",
              },
              {
                __address__ = "localhost",
                __path__    = "${logDir}/pihole/webserver.log",
                job         = "pi-hole-webserver",
                host        = "${host}",
              },
            ]
          }

          loki.source.file "pihole" {
            targets    = local.file_match.pihole.targets
            forward_to = [loki.write.default.receiver]
          }
        '';
    };
}

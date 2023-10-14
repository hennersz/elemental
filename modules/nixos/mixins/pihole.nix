{ pkgs, lib, config, ... }:
{
  options.elemental.pi-hole = with lib; {
    image = mkOption {
      type = types.str;
      default = "pihole/pihole:2023.05.2";
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
  };

  config = {
    virtualisation.oci-containers.containers.pi-hole = {
      inherit (config.elemental.pi-hole) image;
      extraOptions = [
        "--network=host"
        "--dns=127.0.0.1"
        "--dns=9.9.9.9"
        "--hostname=${config.elemental.pi-hole.domain}"
      ];
      environment = {
        WEB_PORT = "${builtins.toString config.elemental.pi-hole.port}";
        VIRTUAL_HOST = config.elemental.pi-hole.domain;
        PROXY_LOCATION = config.elemental.pi-hole.domain;
        FTLCONF_LOCAL_IPV4 = config.elemental.pi-hole.hostIP;
        PIHOLE_DNS_ = lib.strings.concatStringsSep ";" config.elemental.pi-hole.upstreams;
        TZ = config.time.timeZone;
        INTERFACE = builtins.head config.elemental.pi-hole.interfaces;
        WEBPASSWORD = "";
        DNSMASQ_LISTENING = "all";
      };
      volumes = [
        "${config.elemental.pi-hole.dataDir}/pi-hole/etc:/etc/pihole"
        "${config.elemental.pi-hole.dataDir}/pi-hole/dnsmasq:/etc/dnsmasq.d"
        "${config.elemental.pi-hole.dataDir}/pi-hole/log:/var/log"
      ];
    };

    system.activationScripts.pi-hole = ''
      mkdir -p ${config.elemental.pi-hole.dataDir}/pi-hole/etc
      mkdir -p ${config.elemental.pi-hole.dataDir}/pi-hole/dnsmasq
      mkdir -p ${config.elemental.pi-hole.dataDir}/pi-hole/log/pihole
      mkdir -p ${config.elemental.pi-hole.dataDir}/pi-hole/log/lighttpd
    '';

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    services.nginx.virtualHosts."${config.elemental.pi-hole.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString config.elemental.pi-hole.port}";
        proxyWebsockets = true;
      };
    };
  };
}

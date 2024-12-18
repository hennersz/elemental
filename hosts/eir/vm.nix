{ config, lib, pkgs, nixpkgs, hostSystem, ... }:
{
  imports = [ ./configuration.nix ];
  modules = {
    qemuGuest = {
      autoLogin = true;
      dhcp = false;
      user = "henry";
      socketVmnet.enable = lib.mkIf (lib.strings.hasSuffix "darwin" hostSystem) true;
    };
  };
  networking.interfaces.eth0 = lib.mkIf (lib.strings.hasSuffix "darwin" hostSystem) {
    name = "eth0";
    ipv4.addresses = [
      {
        address = "192.168.105.101";
        prefixLength = 24;
      }
    ];
  };

  elemental.pi-hole = {
    interfaces = [ "eth0" "tailscale0" ];
    domain = config.networking.hostName;
    hostIP = if (lib.strings.hasSuffix "darwin" hostSystem) then "192.168.105.101" else "10.0.0.2";
  };
  system.activationScripts.makeAppDataDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/app-data
    chmod 777 /var/lib/app-data
  '';

}

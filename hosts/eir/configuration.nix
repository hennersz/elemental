{ config, pkgs, inputs, outputs, ... }:
let
  hostName = "eir";
  appDataRoot = "/var/lib/app-data";
in
{
  imports = with inputs.self.nixosModules.modules; [
    users-henry
    mixins-common
    mixins-selfupdate
    mixins-vpn
    mixins-metrics-server
    mixins-dashboard-server
    mixins-logging-server
    mixins-pihole
    mixins-nginx
    inputs.vscode-server.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  documentation.man.cache.enable = false;

  system.stateVersion = "22.11";

  # Shared parent for grafana, loki, prometheus, pi-hole, … (subdirs owned by each service).
  systemd.services.elemental-app-data-prepare = {
    description = "Ensure ${appDataRoot} exists with safe permissions";
    before = [
      "grafana-prepare.service"
      "loki-prepare.service"
      "pi-hole-prepare.service"
    ];
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.coreutils}/bin/mkdir -p "${appDataRoot}"
      ${pkgs.coreutils}/bin/chown root:root "${appDataRoot}"
      ${pkgs.coreutils}/bin/chmod 0755 "${appDataRoot}"
    '';
  };

  services.vscode-server.enable = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.henry = inputs.self.homeManagerModules.configs.henry-eir;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };

  mixins.selfupdate = {
    inherit hostName;
    enable = true;
  };

  networking = {
    inherit hostName;
    networkmanager.enable = true;
    networkmanager.insertNameservers = [
      "127.0.0.1"
      "100.100.100.100"
      "9.9.9.9"
    ];
  };

  services.openssh.enable = true;

  nix.settings = {
    max-jobs = 0;
    cores = 1;
  };

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /root/.ssh/id_builder
  '';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
    ];
  };

}

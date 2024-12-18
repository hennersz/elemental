{ config, inputs, outputs, ... }:
let
  hostName = "eir";
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

  documentation.man.generateCaches = false;

  system.stateVersion = "22.11";

  services.vscode-server.enable = true;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.henry = inputs.self.homeManagerModules.configs.henry-eir;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
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

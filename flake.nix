{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv/v0.6.3";
  };
  description = "A flake defining the configuration for my systems";

  outputs = { self, nixpkgs, nixos-hardware, home-manager, vscode-server, devenv, ... }@inputs: 
  let
    nixosModules = import ./modules/nixos { lib = nixpkgs.lib; };
    inherit (self) outputs;
  in
  {
    nixosModules.modules = nixosModules;
    nixosModules.archetypes = import ./archetypes ;
    homeManagerModules.modules = import ./modules/homeManager;
    homeManagerModules.configs = import ./home-manager;

    nixosConfigurations = {
      eir = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [ 
          ./hosts/eir/configuration.nix
          nixos-hardware.nixosModules.raspberry-pi-4
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: {
            services.vscode-server.enable = true;
          })
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.henry = self.homeManagerModules.configs.henry-eir;
            home-manager.extraSpecialArgs = {
              inputs = inputs;
              outputs = self.outputs;
            };
          }
        ];
      };

      hel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs ; }; # Pass flake inputs to our config
        modules = [ 
          ./hosts/hel/configuration.nix
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: {
            services.vscode-server.enable = true;
          })
        ];
      };
    };

    homeConfigurations."henry@hel" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs outputs; };
      modules = [
        ./home-manager/henry-hel.nix
      ];
    };

    homeConfigurations."henry@tyr" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs outputs; };
      modules = [
        ./home-manager/henry-tyr.nix
      ];
    };

    templates = {
      vagrant = {
        description = "Starter for vagrant boxes";
        path = ./templates/vagrant;
      };
      baseDevEnv = {
        description = "basic development environment with no preinstalled tools";
        path = ./templates/devEnvs/base;
      };
    };

    lib = import ./lib { inherit inputs; };
  };
}

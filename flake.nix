{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/51559e691f1493a26f94f1df1aaf516bb507e78b";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixneovim.url = "github:nixneovim/nixneovim";
    nixneovimplugins.url = "github:NixNeovim/NixNeovimPlugins";
  };
  description = "A flake defining the configuration for my systems";

  outputs = { self, nixpkgs, nixos-hardware, home-manager, vscode-server, nixneovim, nixneovimplugins, ... }@inputs: 
  let
    overlays = ({...}: {
      nixpkgs.overlays = [ 
        nixneovim.overlays.default
        nixneovimplugins.overlays.default
      ];
    });
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
        overlays
        nixneovim.nixosModules.homeManager-22-11
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
    };
  };
}

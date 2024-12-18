{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    nix-alien = { url = "github:thiagokokada/nix-alien"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    apple-silicon = { url = "github:tpwrules/nixos-apple-silicon"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    flake-utils.url = "github:numtide/flake-utils";
    std-dev-env.url = "github:hennersz/std-dev-env";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    mrkuz.url = "github:mrkuz/macos-config";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };
  description = "A flake defining the configuration for my systems";

  outputs = { self, nixpkgs-unstable, nixpkgs, nixos-hardware, home-manager, vscode-server, flake-utils, std-dev-env, darwin, mrkuz, ... }@inputs:
    let
      nixosModules = import ./modules/nixos { inherit (nixpkgs-unstable) lib; };

      vars = {
        darwin.stateVersion = 4;
        homeManager.stateVersion = "24.11";
        nixos.stateVersion = "24.11";
        nixos.stableVersion = "24.11";
        rev = self.rev or self.dirtyRev or "dirty";
      };
      inherit (self) outputs;
      utils = import ./utils.nix { inherit vars inputs outputs; };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          lib = nixpkgs-unstable.lib;
          arch = builtins.elemAt (lib.strings.splitString "-" system) 0;
        in
        {
          devShells.default = std-dev-env.lib.base rec {
            inherit inputs;
            pkgs = utils.mkPkgs { inherit system; };
            packages = with pkgs; [
              nixVersions.stable
              statix
              nil
              nixpkgs-fmt
              act
            ];
            scripts.lint.exec = ''
              shopt -s globstar
              statix check "$DEVENV_ROOT"
              nixpkgs-fmt --check "$DEVENV_ROOT"/**/*.nix
            '';
            scripts.format.exec = ''
              shopt -s globstar
              nixpkgs-fmt "$DEVENV_ROOT"/**/*.nix
            '';
          };

          packages.eir-vm = (utils.mkVm {
            name = "eir";
            currentSystem = system;
            selfReference = self;
            targetSystem = "${arch}-linux";
          }).config.system.build.startVm;
        }) // {
      nixosModules.modules = nixosModules;
      nixosModules.archetypes = import ./archetypes;
      homeManagerModules.modules = import ./modules/homeManager;
      homeManagerModules.configs = import ./home-manager;

      nixosConfigurations = {
        eir = nixpkgs-unstable.lib.nixosSystem rec {
          system = "aarch64-linux";
          pkgs = utils.mkPkgs { inherit system; };
          specialArgs = { inherit inputs outputs; }; # Pass flake inputs to our config
          modules = [
            ./hosts/eir/default.nix
          ];
        };

        hel = nixpkgs-unstable.lib.nixosSystem rec {
          system = "x86_64-linux";
          pkgs = utils.mkPkgs { inherit system; };
          specialArgs = { inherit inputs; }; # Pass flake inputs to our config
          modules = [
            ./hosts/hel/configuration.nix
            vscode-server.nixosModules.default
            ({ config, pkgs, ... }: {
              services.vscode-server.enable = true;
            })
          ];
        };

        fenrir = nixpkgs-unstable.lib.nixosSystem rec {
          system = "x86_64-linux";
          pkgs = utils.mkPkgs { inherit system; };
          specialArgs = { inherit inputs; }; # Pass flake inputs to our config
          modules = [
            ./hosts/fenrir/configuration.nix
            vscode-server.nixosModules.default
            ({ config, pkgs, ... }: {
              services.vscode-server.enable = true;
            })
          ];
        };
      };

      homeConfigurations."henry@hel" = home-manager.lib.homeManagerConfiguration {
        pkgs = utils.mkPkgs { system = "x86_64-linux"; };
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./home-manager/henry-hel.nix
        ];
      };

      homeConfigurations."henry@fenrir" = home-manager.lib.homeManagerConfiguration {
        pkgs = utils.mkPkgs { system = "x86_64-linux"; };
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./home-manager/henry-fenrir.nix
        ];
      };

      homeConfigurations."henry@tyr" = home-manager.lib.homeManagerConfiguration {
        pkgs = utils.mkPkgs { system = "x86_64-linux"; };
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./home-manager/henry-tyr.nix
        ];
      };

      homeConfigurations."henry@garmr" = home-manager.lib.homeManagerConfiguration {
        pkgs = utils.mkPkgs { system = "x86_64-linux"; };
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./home-manager/henry-garmr.nix
        ];
      };

      homeConfigurations."henry@codespaces" = home-manager.lib.homeManagerConfiguration {
        pkgs = utils.mkPkgs { system = "x86_64-linux"; };
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./home-manager/henry-codespaces.nix
        ];
      };

      darwinConfigurations = {
        baldur = darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          pkgs = utils.mkPkgs { inherit system; };
          modules = [
            ./hosts/baldur/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.henry = self.homeManagerModules.configs.henry-baldur;
              home-manager.extraSpecialArgs = {
                inherit inputs outputs;
              };
            }
          ];
        };
      };

      templates = {
        vagrant = {
          description = "Starter for vagrant boxes";
          path = ./templates/vagrant;
        };
      };
    };
}

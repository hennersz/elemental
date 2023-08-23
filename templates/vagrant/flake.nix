{ 
  inputs = {
    elemental.url = "github:hennersz/elemental/flakes";
    nixpkgs.follows = "elemental/nixpkgs";
    home-manager.follows = "elemental/home-manager";
  };
  outputs = { self, nixpkgs, elemental, home-manager,  ... }: 
  { 
    nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./hardware-configuration.nix
        ./vagrant.nix
        elemental.nixosModules.archetypes.vagrant
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vagrant = elemental.homeManagerModules.configs.henry-vm;
          home-manager.extraSpecialArgs = {
            inputs = elemental.inputs;
            outputs = elemental.outputs;
          };
        }
      ];
    };
  };
}

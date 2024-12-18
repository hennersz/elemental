{ inputs, outputs, vars, ... }: rec {

  attrsToValues = attrs:
    inputs.nixpkgs.lib.attrsets.mapAttrsToList (name: value: value) attrs;

  extendLib = lib: lib.extend (self: super: {
    hm = inputs.home-manager.lib.hm;
    vmHostAttrs = options: block: if (builtins.hasAttr "cores" options.virtualisation) then block else { };
    buildQemuVm = { name, targetSystem, configuration }:
      (mkVm { inherit name targetSystem configuration; }).config.system.build.startVm;
  });

  overlay-stable = final: prev: {
    stable = inputs.nixpkgs.legacyPackages.${prev.system};
  };

  mkPkgs = { system, nixpkgs ? inputs.nixpkgs-unstable }: import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.apple-silicon.overlays.apple-silicon-overlay
      inputs.nix-alien.overlays.default
      overlay-stable
      (_: super: inputs.mrkuz.packages."${system}")
    ] ++ attrsToValues inputs.mrkuz.overlays;
  };

  mkVm =
    { name
    , currentSystem
    , targetSystem
    , systemVars ? { }
    , selfReference ? inputs.self
    , nixpkgs ? inputs.nixpkgs-unstable
    , hostPkgs ? mkPkgs { inherit nixpkgs; system = currentSystem; }
    , profile ? ./profiles/nixos/qemu-vm.nix
    , configuration ? { imports = [ (./hosts + "/${name}/vm.nix") ]; }
    }:
    let
      lib = extendLib nixpkgs.lib;
      mergedVars = vars // systemVars;
    in
    lib.nixosSystem {
      specialArgs = {
        inherit nixpkgs inputs outputs;
        self = selfReference;
        systemName = name;
        hostSystem = currentSystem;
        vars = mergedVars;
          };
        modules = [
          (import ./modules/nixos/qemu-guest.nix)
          profile
          ({ lib, options, ... }: {
            networking.hostName = lib.mkDefault name;
            nixpkgs.pkgs = mkPkgs { system = targetSystem; inherit nixpkgs; };
            modules.qemuGuest.enable = true;
            virtualisation = lib.vmHostAttrs options {
              host.pkgs = hostPkgs;
            };

            system = {
              inherit name;
              stateVersion = lib.mkDefault mergedVars.nixos.stateVersion;
              configurationRevision = mergedVars.rev;
            };

          })
          configuration
        ];
      };
}

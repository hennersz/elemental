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
    stable = import inputs.nixpkgs { inherit (prev) system; config.allowUnfree = true; };
  };

  overlay-avante = final: prev:
    let
      avante = prev.vimPlugins.avante-nvim;
      avanteLib = avante.passthru.avante-nvim-lib;
      patchedAvanteLib = avanteLib.overrideAttrs (old: {
        dontCargoUseSystemLibs = true;
      });
    in
    {
      vimPlugins = prev.vimPlugins // {
        avante-nvim = avante.overrideAttrs (old: {
          postInstall = builtins.replaceStrings
            [ "${avanteLib}" ]
            [ "${patchedAvanteLib}" ]
            old.postInstall;
          passthru = old.passthru // {
            avante-nvim-lib = patchedAvanteLib;
          };
        });
      };
    };

  mkPkgs = { system, nixpkgs ? inputs.nixpkgs-unstable }: import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    config.permittedInsecurePackages = [
      "electron-27.3.11"
      "electron-39.8.10"
    ];
    overlays =
      if (system == "aarch64-darwin") then [
        overlay-avante
        inputs.apple-silicon.overlays.apple-silicon-overlay
        inputs.nix-alien.overlays.default
        overlay-stable
        (_: super: inputs.mrkuz.packages."${system}")
      ] else [
        overlay-avante
        inputs.nix-alien.overlays.default
        overlay-stable
      ];
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

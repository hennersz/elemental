{ nixpkgs, devenv, inputs}:{ pkgs, system, funtionOverrides? {}, packages? [], modules? []}:
let
  stdFunctions = {
    tests = "echo tests not implemented; exit 1";
    lint = "echo lint not implemented; exit 1";
    check = ''
    lint
    tests
    '';
    up = "devenv up";
    clean = "echo clean not implemented; exit 1";
    upgrade = "nix flake update";
  } // funtionOverrides;

  stdFunctionPackages = (nixpkgs.lib.attrsets.foldlAttrs (acc: name: script: acc ++ [(pkgs.writeShellScriptBin name script)] ) [] stdFunctions );
in
devenv.lib.mkShell {
  inherit pkgs inputs;
  modules = [
    ({pkgs, ...}: {
      packages = stdFunctionPackages ++ packages;
    })
  ] ++ modules ;
}
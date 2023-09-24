{ nixpkgs }:
let
  forAllSystems = function: nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
  ] (
    system:
    let
      pkgs = import nixpkgs { inherit system; };
    in  
      function { inherit pkgs system; }
  );
in
{
  inherit forAllSystems;
}
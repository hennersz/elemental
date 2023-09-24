{inputs}:
let
  nixpkgs = inputs.nixpkgs;
  devenv = inputs.devenv;
  helpers = import ./helpers { inherit nixpkgs; };
in
{
  stdDevEnv = import ./stdDevEnv { inherit nixpkgs devenv inputs; };
} // helpers
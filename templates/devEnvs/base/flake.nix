{
  inputs = {
    elemental.url = "github:hennersz/elemental";
  };

  outputs = { self, elemental, ... }@inputs:
  {
    devShells = elemental.lib.forAllSystems( {pkgs, system}: {
      default = elemental.lib.stdDevEnv {
        inherit system pkgs;
      };
    });
  };
}
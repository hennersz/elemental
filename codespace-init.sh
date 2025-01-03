#! /usr/bin/env bash

cat > ~/.config/home-manager/flake.nix << EOF
{
  description = "Home Manager configuration for codespaces";

  inputs = {
    elemental.url = "github:hennersz/elemental";
  };

  outputs = { self, elemental, ... }@inputs: {
    homeConfigurations.codespace = elemental.homeConfigurations."henry@codespaces";
  };
}
EOF

nix run home-manager#home-manager -- --flake ~/.config/home-manager
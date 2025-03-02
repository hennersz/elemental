#! /usr/bin/env bash

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
mkdir -p ~/.config/home-manager
cat > ~/.config/home-manager/flake.nix << EOF
{
  description = "Home Manager configuration for codespaces";

  inputs = {
    elemental.url = "git+file:///home/codespace/dotfiles";
  };

  outputs = { self, elemental, ... }@inputs: {
    homeConfigurations.codespace = elemental.homeConfigurations."henry@codespaces";
  };
}
EOF

nix run home-manager#home-manager -- switch --flake ~/.config/home-manager

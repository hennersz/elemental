#! /usr/bin/env bash

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >>~/.config/nix/nix.conf
mkdir -p ~/.config/home-manager
cat >~/.config/home-manager/flake.nix <<EOF
{
  description = "Home Manager configuration for ubuntu";

  inputs = {
    elemental.url = "git+file:///home/ubuntu/dotfiles";
  };

  outputs = { self, elemental, ... }@inputs: {
    homeConfigurations.ubuntu = elemental.homeConfigurations."henry@ubuntu";
  };
}
EOF

nix run home-manager#home-manager -- switch --flake ~/.config/home-manager

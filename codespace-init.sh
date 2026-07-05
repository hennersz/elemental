#! /usr/bin/env bash
set -euo pipefail

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >~/.config/nix/nix.conf
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

mkdir -p ~/.local/state/nix/profiles
mkdir -p ~/.local/state/home-manager/gcroots

# The devcontainers/nix feature was built assuming user=codespace, leaving
# ~/.nix-profile pointing at /home/codespace/... Remove it so Nix recreates
# the symlink against the real $HOME on first profile install.
if [ -L ~/.nix-profile ] && [[ "$(readlink ~/.nix-profile)" != "$HOME/"* ]]; then
	rm ~/.nix-profile
fi

nix run home-manager#home-manager -- switch --flake ~/.config/home-manager

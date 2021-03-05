#! /bin/bash

set -e

curl -L https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
home-manager switch

sudo echo "/usr/local/bin/fish" >> /etc/shells
chsh --shell /usr/local/bin/fish
fish
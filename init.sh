#!/bin/bash

set -e

os=$(uname)
if [ "$os" = "Darwin" ]; then 
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  . ./vercomp.sh
  ver=$(sw_vers -productVersion)
  (vercomp "$ver" "10.14") && true
  if [ $? = 1 ]; then 
    sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
  else
    curl -L https://nixos.org/nix/install | sh
  fi
else
  curl -L https://nixos.org/nix/install | sh
fi

# shellcheck source=/dev/null
. ~/.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

export NIX_PATH=home-manager=${HOME}/.nix-defexpr/channels/home-manager:nixpkgs=${HOME}/.nix-defexpr/channels/nixpkgs
nix-shell '<home-manager>' -A install
home-manager switch

echo "/usr/local/bin/fish" | sudo tee -a /etc/shells > /dev/null
chsh -s /usr/local/bin/fish
fish

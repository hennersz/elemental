function nixUpdate
  set originalDir (pwd)
  cd ~/.config/nixpkgs
  and git pull
  and git submodule update --remote --recursive --init
  and nix-channel --update
  and home-manager switch
  and cd $originalDir
end
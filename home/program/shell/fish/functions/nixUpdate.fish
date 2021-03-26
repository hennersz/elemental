function nixUpdate
  set originalDir (pwd)
  cd ~/.config/nixpkgs
  and git pull --recurse-submodules
  and nix-channel --update
  and home-manager switch
  and cd $originalDir
end
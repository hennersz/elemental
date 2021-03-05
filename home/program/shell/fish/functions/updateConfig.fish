function updateConfig
  set originalDir (pwd)
  cd ~/.config/nixpkgs
  and git pull
  and nix-channel --update
  and home-manager switch
  and cd $originalDir
end
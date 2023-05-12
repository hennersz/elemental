function nixClean
  nix-collect-garbage --delete-older-than 30d
end
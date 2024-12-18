function nixUpdate
  if test -e /etc/nixos/flake.nix
    sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch
  end

  if test -e ~/.config/home-manager/flake.nix
    nix flake update --flake ~/.config/home-manager && home-manager switch
  end
end
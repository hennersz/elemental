{ config, lib, ... }:

{
  imports = [
    ./program/default.nix
    ./role/default.nix
    ./user/default.nix
    ./identity/default.nix
    ./machine/default.nix
    ./elemental.nix
  ];

  xdg.enable = true;
  manual.manpages.enable = false;
  programs.home-manager.enable = true;
  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

}

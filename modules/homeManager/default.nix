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
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

}

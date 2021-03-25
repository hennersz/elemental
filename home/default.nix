{ config, lib, ... }:

{
  imports = [
    ./program/default.nix
    ./role/default.nix
    ./user/default.nix
    ./identity/default.nix
    ./machine/default.nix
  ];

  xdg.enable = true;
  manual.manpages.enable = false;
}

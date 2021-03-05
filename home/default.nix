{ config, lib, ... }:

{
  imports = [
    ./program/default.nix
    ./role/default.nix
    ./user/default.nix
  ];

  xdg.enable = true;
  manual.manpages.enable = false;
}

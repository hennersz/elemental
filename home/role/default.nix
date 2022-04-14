{ config, lib, stdenv, ... }:
{
  imports = [
    ./darwin-laptop/default.nix
    ./linux-vm/default.nix
    ./linux-desktop/default.nix
  ];
}

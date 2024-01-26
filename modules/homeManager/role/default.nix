{ config, lib, stdenv, ... }:
{
  imports = [
    ./darwin-workstation/default.nix
    ./linux-vm/default.nix
    ./linux-workstation/default.nix
    ./nixos-workstation/default.nix
  ];
}

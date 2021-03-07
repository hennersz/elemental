{ config, pkgs, lib,... }:

{
  imports = [
    ./elemental.nix

    ./home/default.nix
  ];

  # Let Home Manager install itself
  programs.home-manager.enable = true;
  # Allow unfree
  nixpkgs.config.allowUnfree = true;

  elemental.role = "linux-vm";
  elemental.user = "henry";
}
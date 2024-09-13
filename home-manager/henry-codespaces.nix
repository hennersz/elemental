{ lib, config, pkgs, inputs, outputs, ... }: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.modules
  ];

  elemental.role = "codespaces";
  elemental.user = "henry";
  elemental.machine = "codespaces";
  elemental.identity = "none";
  home.homeDirectory = lib.mkForce "/home/codespace";

  home.stateVersion = "24.05";
}

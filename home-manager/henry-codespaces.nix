{ lib, config, pkgs, inputs, outputs, ... }: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.modules
  ];

  elemental.role = "codespace";
  elemental.user = "codespace";
  elemental.machine = "codespace";
  elemental.identity = "none";
  home.homeDirectory = lib.mkForce "/home/codespace";

  home.stateVersion = "25.05";
}

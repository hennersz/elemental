{ lib, config, pkgs, inputs, outputs, ... }: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.modules
  ];

  elemental = {
    role = "codespace";
    user = "codespace";
    machine = "codespace";
    identity = "none";
  };
  home.homeDirectory = lib.mkForce "/home/codespace";

  home.stateVersion = "25.05";
}

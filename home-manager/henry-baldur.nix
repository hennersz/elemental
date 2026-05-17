{ lib, config, pkgs, inputs, outputs, ... }: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.modules
  ];

  elemental = {
    role = "darwin-laptop";
    user = "henry";
    machine = "baldur";
    identity = "neo4j";
    home.program.terminal.alacritty.enable = true;
  };
  home.homeDirectory = lib.mkForce "/Users/henry";

  home.stateVersion = "24.05";
}

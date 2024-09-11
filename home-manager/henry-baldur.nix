{ lib, config, pkgs, inputs, outputs, ... }: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.modules
  ];

  elemental.role = "darwin-laptop";
  elemental.user = "henry";
  elemental.machine = "baldur";
  elemental.identity = "neo4j";
  elemental.home.program.terminal.alacritty.enable = true;
  home.homeDirectory = lib.mkForce "/Users/henry";

  home.stateVersion = "24.05";
}

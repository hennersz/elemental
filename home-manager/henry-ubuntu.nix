{ lib, config, pkgs, inputs, outputs, ... }: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.modules
  ];

  elemental = {
    role = "ubuntu";
    user = "ubuntu";
    machine = "ubuntu";
    identity = "none";
  };
  elemental.home.program.editor.neovim.enable = true;
  home.homeDirectory = lib.mkForce "/home/ubuntu";

  home.stateVersion = "25.05";
}

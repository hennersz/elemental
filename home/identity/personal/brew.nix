{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "personal" && config.elemental.role == "darwin-laptop") {
    home.file.extensions = {
      source = ./Brewfile;
      target = ".config/brew/Brewfile";
      onChange = "brew bundle --file ~/.config/brew/Brewfile --cleanup --no-lock";
    };
  };
}
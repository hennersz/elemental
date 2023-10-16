{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.elemental.home.program.editor.vscode;
in
{
  options.elemental.home.program.editor.vscode = {
    enable = mkEnableOption "Enable vscode";
  };

  config = mkIf cfg.enable {
    elemental.home.program.dev.git.extraConfig.core.editor = "code --wait --reuse-window";

    home.file.extensions = {
      source = ./extensions.list;
      target = ".config/Code/extensions.list";
      onChange = "cat ~/.config/Code/extensions.list | grep -v '^#' | xargs -L1 code --force --install-extension ";
    };

    xdg.configFile."Code/User/keybindings.json".source = ./keybindings.json;
    xdg.configFile."Code/User/settings.json".source = ./settings.json;

    home.packages = with pkgs; [
      vscode
    ];
  };

}

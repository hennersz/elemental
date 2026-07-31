{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.elemental.machine == "baldur") {
    elemental.home.program.editor.neovim.anthropicApiKeyRef = "op://Private/Anthropic API Key/credential";

    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/Users/henry/Credentials/passwords";
      };
    };

    home.packages = with pkgs; [
      zed-editor
    ];
  };
}

{ config, lib, ... }:
with lib;
{
  config = mkIf (config.elemental.machine == "freyr") {
    elemental.home.program.credentials.gpg.home = "/home/henry/Credentials/gpg";
    home.sessionVariables = {
      VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH = "/mnt/c/Users/Henry";
      VAGRANT_WSL_ENABLE_WINDOWS_ACCESS = "1";
      ELEMENTAL_SOURCE_DIR = "/home/henry/.config/nixpkgs";
    };

    elemental.home.program.shell.fish.preShellInit = "set -x PATH $PATH \"/mnt/c/Program Files/Oracle/VirtualBox\"\n";

    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/home/henry/Credentials/passwords";
      };
    };
  };
}
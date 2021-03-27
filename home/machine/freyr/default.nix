{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.machine == "freyr") {
      home.sessionVariables = {
          VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH = "/mnt/c/Users/Henry";
          VARGRANT_DEFAULT_PROVIDER = "hyperv";
          VAGRANT_WSL_ENABLE_WINDOWS_ACCESS = "1";
      };
  };
}
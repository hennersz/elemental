{ config, lib, pkgs, ...}:
with lib;
let 
  cfg = config.elemental.home.program.credentials.onePassword;
in
{
  options.elemental.home.program.credentials.onePassword = {
    enable = mkEnableOption "Enable 1password";
    account = mkOption {
      type = types.str;
      description = "The 1password account to login as";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "fish/conf.d/opLogin.fish" = {
        source = ./opLogin.fish;
        executable = false;
      };
    };
  };
}
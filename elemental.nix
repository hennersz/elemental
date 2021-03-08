{ config, lib, pkgs, ... }:
let
  cfg = config.elemental;
in
{

  options.elemental.machine = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      The hostname of the device, this determines configration specific to the machine/hardware
    '';
    example = "boron";
  };

  options.elemental.role = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      The device role, this determines OS specific configuration.
    '';
    example = "workstation";
  };

  options.elemental.user = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      The primary user, this determines the CLI utilities to install
    '';
    example = "henry";
  };

  options.elemental.identity = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      The identity of the user, determines ssh, git, etc identiies 
      and GUI apps to install when combined with a role.
    '';
    example = "personal";
  };
}

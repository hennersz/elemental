{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.elemental.home.program.credentials.gpg;
  primitiveType = types.oneOf [ types.str types.bool ];
in
{
  options.elemental.home.program.credentials.gpg = {
    enable = mkEnableOption "Enable GPG";

    homedir = mkOption {
      type = types.path;
      description = "The gpg home directory";
      default = "${config.home.homeDirectory}/.gnupg";
    };

    settings = mkOption {
      type = types.attrsOf (types.either primitiveType (types.listOf types.str));
      example = literalExample ''
        {
          no-comments = false;
          s2k-cipher-algo = "AES128";
        }
      '';
      description = ''
        GnuPG configuration options. Available options are described
        in the gpg manpage:
        <link xlink:href="https://gnupg.org/documentation/manpage.html"/>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      inherit (cfg) settings homedir;
      enable = true;

      publicKeys = [
        { source = ./publicKeys/personal.asc; }
        { source = ./publicKeys/controlPlane.asc; }
      ];
    };

    services = mkIf ((strings.hasPrefix "linux" config.elemental.role) || (strings.hasPrefix "nix" config.elemental.role))  {
      gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };
    };

    # forcibly overwrite SSH_AUTH_SOCK
    programs.fish.interactiveShellInit = ''
      set -gx SSH_AUTH_SOCK (${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)
    '';
  };
}

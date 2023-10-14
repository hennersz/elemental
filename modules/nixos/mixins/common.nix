{ config, pkgs, lib, ... }:
with
lib;
{
  options.elemental.domainName = mkOption {
    type = types.string;
    default = "";
  };

  config = {
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      # Free up to 1GiB whenever there is less than 100MiB left.
      extraOptions = ''
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';
    };

    programs.fish.enable = true;

    time.timeZone = "Europe/London";
    nixpkgs.config.allowUnfree = true;
  };
}

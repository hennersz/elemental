{ config, lib, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "personal") {
    home.sessionVariables = {
      VAULT_ADDR = "http://vault.lan.morti.net:8200";
    };
  };
}

{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.elemental.identity == "neo4j") {
    programs.password-store.settings = {
      PASSWORD_STORE_SIGNING_KEY = "486EBCAEA5918639CCD6858FE80F01751AE0A7CE 2BE0BAB0E0F81C7EFC992F5EA9361CEA6825688D";
    };
  };
}

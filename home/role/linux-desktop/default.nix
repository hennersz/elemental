{ config, lib, pkgs, ... }:
with
lib;
{

  config = mkIf (config.elemental.role == "linux-desktop") {
    elemental.home.program = {
      editor.vscode.enable = true;
    };

    # Environment
    home.sessionVariables = {
      EDITOR = "code --wait";
    };

    home.packages = with pkgs; [
      buildah
      docker
      docker-compose
      podman
      slack
      vscode
      pdfarranger
    ];

    programs.fish.shellAliases = {
      kyverno = "sudo docker run --rm -v (pwd):/mount -u 1000 -w /mount ghcr.io/kyverno/kyverno-cli:1.8-dev-latest";
      # kyverno = "sudo docker run --rm -v (pwd):/mount -u 1000 -w /mount --entrypoint /kyverno ghcr.io/kyverno/kyverno-cli:v1.7.4";
    };
  };
}

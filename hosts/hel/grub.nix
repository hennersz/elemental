{ config, pkgs, inputs, ... }:
let
  grubTheme = pkgs.fetchFromGitHub {
    owner = "Patato777";
    repo = "dotfiles";
    rev = "9762695c4453be963d2d88e43c7207b9b8fe59ed";
    sha256 = "0c5vg0zaa6dzapl9zzy1slv7ci168g3da9mx9y9ld8d50kfihcav";
  };
in
{
  boot.loader.grub = {
    default = "saved";
    useOSProber = true;
    enable = true;
    efiSupport = true;
    gfxmodeEfi = "1920x1080x32";
    devices = [ "nodev" ];
    extraConfig = ''
      set theme=($drive1)//themes/virtuaverse/theme.txt
      export GRUB_COLOR_NORMAL="light-gray/black"
      export GRUB_COLOR_HIGHLIGHT="magenta/black"
    '';

    splashImage = "${grubTheme}/grub/themes/virtuaverse/background.png";
  };

  system.activationScripts.copyGrubTheme = ''
    mkdir -p /boot/themes
    cp -R ${grubTheme}/grub/themes/virtuaverse/ /boot/themes/virtuaverse
  '';
}

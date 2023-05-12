{ config, pkgs, lib, ... }:
{
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}

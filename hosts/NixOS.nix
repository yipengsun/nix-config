{ suites, ... }:
{
  ### root password is MY default ROOT password! ###
  imports = suites.base;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };
}

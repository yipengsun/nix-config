{ lib, pkgs, config, ... }:

with lib;
{
  system.stateVersion = "22.11";

  ##############
  # WSL bundle #
  ##############

  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "syp";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  #################
  # System config #
  #################

  imports = suites.server;

  ###############
  # User config #
  ###############

  home-manager.users.syp = { suites, ... }: {
    imports = suites.server;
  };
}

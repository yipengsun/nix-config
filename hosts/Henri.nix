{ pkgs, config, modulesPath, suites, ... }:

{
  system.stateVersion = "22.11";

  ##############
  # WSL bundle #
  ##############

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
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

  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ] ++ suites.wsl;

  ###############
  # User config #
  ###############

  users.allowNoPasswordLogin = true; # another WSL hack

  home-manager.users.syp = { suites, ... }: {
    imports = suites.server;
  };
}

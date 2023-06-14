{ pkgs, config, modulesPath, suites, ... }:

{
  system.stateVersion = "22.11";

  ##############
  # WSL bundle #
  ##############

  wsl = {
    enable = true;
    startMenuLaunchers = false;
    nativeSystemd = false; # a dangerous proposition
    defaultUser = "syp";

    wslConf = {
      automount.root = "/mnt";
    };

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  # special treatment for containers
  # see https://github.com/NixOS/nixpkgs/issues/119841
  environment.noXlibs = false;

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

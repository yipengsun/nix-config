{ pkgs
, config
, modulesPath
, suites
, ...
}: {
  system.stateVersion = "22.11";

  ##############
  # WSL bundle #
  ##############

  wsl = {
    enable = true;
    startMenuLaunchers = false;
    nativeSystemd = true; # a dangerous proposition, as the installer doesn't support it yet
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

  imports =
    [
      "${modulesPath}/profiles/minimal.nix"
    ]
    ++ suites.wsl;

  ############
  # Services #
  ############

  # we don't have enough RAM, really!
  nix.settings.max-jobs = 2;
  nix.settings.cores = 12;

  ###############
  # User config #
  ###############

  #users.allowNoPasswordLogin = true; # another WSL hack

  home-manager.users.syp = { suites, ... }: {
    imports = suites.wsl;
  };
}

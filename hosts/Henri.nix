{ modulesPath, ... }: {
  ##############
  # wsl bundle #
  ##############

  wsl = {
    enable = true;

    defaultUser = "syp";

    nativeSystemd = true;
    useWindowsDriver = true;

    wslConf = {
      automount.root = "/mnt";
    };

    # enable integration with docker desktop (must be installed on windows)
    # docker-desktop.enable = true;
  };

  # special treatment for containers
  # see https://github.com/NixOS/nixpkgs/issues/119841
  environment.noXlibs = false;


  #################
  # system config #
  #################

  imports =
    [
      "${modulesPath}/profiles/minimal.nix"
    ];

  system.stateVersion = "24.05";


  ############
  # services #
  ############

  # we don't have enough ram, really!
  nix.settings.max-jobs = 2;
  nix.settings.cores = 12;
}

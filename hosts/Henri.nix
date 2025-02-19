{ modulesPath, ... }: {
  system.stateVersion = "24.11";


  ##############
  # WSL config #
  ##############

  wsl = {
    enable = true;

    defaultUser = "syp";
    useWindowsDriver = true;

    wslConf = {
      automount.root = "/mnt";
    };

    # Enable integration with docker desktop (must be installed on Windows)
    # docker-desktop.enable = true;
  };


  #################
  # System config #
  #################

  imports =
    [
      "${modulesPath}/profiles/minimal.nix"
    ];


  ############
  # Services #
  ############

  # We don't have enough RAM, really!
  nix.settings.max-jobs = 2;
  nix.settings.cores = 12;
}

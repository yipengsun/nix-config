{ modulesPath, ... }: {
  system.stateVersion = "24.05";


  ##############
  # WSL config #
  ##############

  wsl = {
    enable = true;

    defaultUser = "syp";

    nativeSystemd = true;
    useWindowsDriver = true;

    wslConf = {
      automount.root = "/mnt";
    };

    # Enable integration with docker desktop (must be installed on Windows)
    # docker-desktop.enable = true;
  };

  # Special treatment for containers, see
  #   https://github.com/NixOS/nixpkgs/issues/119841
  environment.noXlibs = false;


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

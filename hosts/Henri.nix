{
  modulesPath,
  self,
  ...
}:
{
  system.stateVersion = "26.11";

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

  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ]
  ++ self.suites.nixos.wsl
  ++ (with self.users; [
    root
    syp
  ]);

  home-manager.users.syp = {
    imports = self.suites.home.wsl;
    im-select.enable = false;
  };

  ############
  # Services #
  ############

  # We don't have enough RAM, really!
  nix.settings.max-jobs = 2;
  nix.settings.cores = 12;
}

{ profiles }:
rec {
  common = {
    common-base = with profiles.shared; [
      cachix
      core
    ];
  };

  nixos = with profiles.nixos; rec {
    base = common.common-base ++ [ core-nixos ];
    services = [
      zfs
      docker
    ];

    # typical use cases
    workstation =
      base
      ++ services
      ++ [
        lang-region
        pam-automount
        dev
        lockscreen
        keyring
      ];
    server = base ++ services ++ [ lang-region ];
    wsl = base ++ [
      lang-region
      wsl-vscode-remote
      dev
    ];
  };

  darwin = with profiles.darwin; rec {
    base = common.common-base ++ [ core-darwin ];

    # typical use cases
    workstation = base ++ [
      aerospace
      dev
      homebrew
    ];
  };

  home = with profiles.home; rec {
    base = [
      hm-state-version
      git
      fish
      fzf
      bat
      neovim
      tmux
      ranger
    ];
    coding = [
      dev
      direnv
      python
    ];

    linux-config-cli = [
      xdg-user-dirs
      dircolors
    ];
    linux-config-gui = [
      xdg-mime-apps
      fontconfig
      gui
    ];

    # typical use cases
    workstation =
      base
      ++ coding
      ++ linux-config-cli
      ++ linux-config-gui
      ++ [
        apps
        zathura
        dev-secrets
      ]
      ++ [
        apps-extra
        www
        term
        ledger
        mpv
        vscode
        passwd-mgr
      ];
    server = base ++ coding ++ linux-config-cli;
    wsl =
      base
      ++ coding
      ++ linux-config-cli
      ++ [
        apps
        zathura
        dev-secrets
      ];
    darwin =
      base
      ++ coding
      ++ [ dev-secrets ]
      ++ [
        www
        term
        mpv
        vscode
        passwd-mgr
        xquartz
      ];
  };
}

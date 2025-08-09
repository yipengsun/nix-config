{
  description = "Yipeng Sun's NixOS/nix-darwin config.";


  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };


  outputs =
    { flake-parts, haumea, ... } @ inputs:
    let
      # helper functions
      stripDefault = x:
        if builtins.isAttrs x
        then
          if x ? default
          then x.default
          else builtins.mapAttrs (name: value: stripDefault value) x
        else
          x;

      setToList = set: with builtins; (map (key: getAttr key set) (attrNames set));

      loadStripped = src:
        let
          attrs = haumea.lib.load {
            src = src;
            loader = haumea.lib.loaders.path;
          };
        in
        stripDefault attrs;

      loadStrippedAsList = src: setToList (loadStripped src);
    in
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }: {
      imports = [
        # third-party libs
        inputs.git-hooks.flakeModule

        # devShell
        ./lib/devShell.nix

        # local modules
        ./lib/configNixpkgs.nix
        ./lib/systemBuilder.nix
      ];

      config = rec {
        debug = true;
        systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

        flake.overlays = {
          default = import ./overlays/default;
        };

        configNixpkgs = {
          config = {
            allowUnfree = true;
          };
          overlays = [
            inputs.agenix.overlays.default
            inputs.nur.overlays.default
            inputs.nix-darwin.overlays.default
          ] ++ [ flake.overlays.default ];
        };

        systemBuilder = {
          hostModuleDir = ./hosts;
          hosts = {
            Henri = {
              system = "x86_64-linux";
              suites = flake.suites.nixos.wsl
                ++
                (with flake.users; [ root syp ]);
              extraConfig = {
                home-manager.users.syp = { self, ... }: {
                  imports = self.suites.home.wsl;
                  im-select.enable = false;
                };
              };
            };

            Thomas = {
              system = "x86_64-linux";
              suites = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1 ];
            };

            Michael = {
              system = "x86_64-linux";
            };

            Leonardo = {
              system = "aarch64-darwin";
            };
          };

          # modules applied to all hosts
          nixosModules = loadStrippedAsList ./modules/nixos
            ++
            [
              inputs.agenix.nixosModules.default
              inputs.nixos-wsl.nixosModules.default
              inputs.disko.nixosModules.disko
            ];
          darwinModules = [ ]
            ++
            [
              inputs.agenix.darwinModules.default
              inputs.mac-app-util.darwinModules.default
              inputs.nix-homebrew.darwinModules.nix-homebrew
            ];
          homeModules = loadStrippedAsList ./modules/home
            ++
            [
              inputs.agenix.homeManagerModules.default
              inputs.mac-app-util.homeManagerModules.default
            ];
        };

        flake.users = loadStripped ./users;
        flake.profiles = loadStripped ./profiles;

        flake.suites.common = {
          common-base = with flake.profiles.shared; [ cachix core ];
        };

        flake.suites.nixos =
          with flake.profiles.nixos; rec {
            base = flake.suites.common.common-base ++ [ core-nixos ];
            services = [ zfs docker ];

            # typical use cases
            workstation = base ++ services ++ [ lang-region pam-automount dev lockscreen keyring ];
            server = base ++ services ++ [ lang-region ];
            wsl = base ++ [ lang-region wsl-vscode-remote dev ];
          };

        flake.suites.darwin =
          with flake.profiles.darwin; rec {
            base = flake.suites.common.common-base ++ [ core-darwin ];

            # typical use cases
            workstation = base ++ [ aerospace dev homebrew ];
          };

        flake.suites.home =
          with flake.profiles.home; rec {
            base = [ hm-state-version git fish fzf bat neovim tmux ranger ];
            coding = [ dev direnv python ];

            linux-config-cli = [ xdg-user-dirs dircolors ];
            linux-config-gui = [ xdg-mime-apps fontconfig gui ];

            # typical use cases
            workstation = base ++ coding ++ linux-config-cli ++ linux-config-gui ++
              [ apps zathura dev-secrets ] ++ [ apps-extra www term ledger mpv vscode passwd-mgr ];
            server = base ++ coding ++ linux-config-cli;
            wsl = base ++ coding ++ linux-config-cli ++
              [ apps zathura dev-secrets ];
            darwin = base ++ coding ++ [ dev-secrets ] ++ [ www term mpv vscode passwd-mgr ];
          };
      };
    });


  inputs = {
    nixpkgs-pointer.url = "github:yipengsun/nixpkgs-pointer";
    nixpkgs.follows = "nixpkgs-pointer/nixpkgs";

    # libs
    flake-parts.follows = "nixpkgs-pointer/flake-parts";

    haumea.url = "github:nix-community/haumea";
    haumea.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # deployment
    #colmena.url = "github:zhaofengli/colmena";
    #colmena.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager, nix-darwin, NixOS-WSL
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # agenix with home-manager integration
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # additional packages/modules
    nur.url = "github:nix-community/NUR";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    mac-app-util.url = "github:hraban/mac-app-util";
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };
}

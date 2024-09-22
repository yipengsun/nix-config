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
    { self
    , flake-parts
    , haumea
    , ...
    } @ inputs:
    let
      # helper functions
      stripDefault = x:
        if builtins.isAttrs x
        then
          if builtins.hasAttr "default" x
          then x.default
          else builtins.mapAttrs (name: value: stripDefault value) x
        else
          x;

      loadStripped = src:
        let
          attrs = haumea.lib.load {
            src = src;
            loader = haumea.lib.loaders.path;
          };
        in
        stripDefault attrs;

      loadStrippedAsList = src:
        let
          attrs = loadStripped src;
        in
        (map (key: builtins.getAttr key attrs) (builtins.attrNames attrs));
    in
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }: {
      imports = [
        # third-party libs
        inputs.git-hooks.flakeModule

        # devShell
        ./lib/devShell.nix

        # local modules
        ./lib/localNixpkgs.nix
        ./lib/systemBuilder.nix
      ];

      config = rec {
        debug = true;
        systems = [ "x86_64-linux" "x86_64-darwin" ];

        flake.overlays = {
          default = import ./overlays/default;
        };

        localNixpkgs = {
          config = {
            allowUnfree = true;
          };
          overlays = [
            inputs.agenix.overlays.default
            inputs.nur.overlay
          ] ++ [ flake.overlays.default ];
        };

        # hosts
        systemBuilder = {
          hosts = {
            Henri = {
              system = "x86_64-linux";
              suites = flake.suites.nixos.wsl
                ++
                (with flake.users; [ root syp ]);
              #homeSuites = flake.suites.home.wsl;
            };
          };
          hostModuleDir = ./hosts;

          # modules applied to all* hosts
          nixosModules = [
            inputs.agenix.nixosModules.default
            inputs.nixos-wsl.nixosModules.default
          ];
          homeModules = [ ] /*(loadStrippedAsList ./modules/home)*/
            ++
            [
              inputs.agenix.homeManagerModules.default
            ];
        };

        # users
        flake.users = loadStripped ./users;

        # profiles & suites
        flake.profiles = loadStripped ./profiles;

        flake.suites.common = {
          base = with flake.profiles.nixos; [ cachix core ];
        };

        flake.suites.nixos =
          let
            profiles = flake.profiles.nixos;
          in
          rec {
            inherit (flake.suites.common) base;

            services = with profiles; [ zfs docker ];

            laptop = base ++ services ++ (with profiles.nixos; [ lang-region-mobile encfs-automount ]);
            wsl = base ++ (with profiles; [ lang-region-mobile ]);
          };

        flake.suites.home =
          let
            profiles = self.profiles.home;
          in
          rec {
            base = with profiles; [ hm-state-version git zsh python neovim tmux ranger ];

            common-apps = with profiles; [ apps www term ];
            coding = with profiles; [ dev bat direnv fzf ];
            multimedia = with profiles; [ mpv mpd ];
            prod = with profiles; [ zathura ledger dev-secrets ];

            # settings
            linux-config-cli = with profiles; [ xdg-user-dirs dircolors ];
            linux-config-gui = with profiles; [ xdg-mime-apps fontconfig wm gui ];

            workstation = base ++ common-apps ++ coding ++ multimedia ++ prod ++
              linux-config-cli ++ linux-config-gui;
            server = base ++ coding ++ linux-config-cli;
            wsl = base ++ (with profiles; [ apps-wsl zathura ]) ++ coding ++ prod ++ linux-config-cli;
          };
      };
    });


  inputs = {
    nixpkgs-pointer.url = "github:yipengsun/nixpkgs-pointer";
    nixpkgs.follows = "nixpkgs-pointer/nixpkgs";

    # libs
    flake-parts.url = "github:hercules-ci/flake-parts";
    haumea.url = "github:nix-community/haumea";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # deployment
    #colmena.url = "github:zhaofengli/colmena";
    #colmena.inputs.nixpkgs.follows = "nixpkgs";

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

    nixos-cn.url = "github:nixos-cn/flakes";
    nixos-cn.inputs.nixpkgs.follows = "nixpkgs";

    berberman.url = "github:berberman/flakes";
    berberman.inputs.nixpkgs.follows = "nixpkgs";
  };

  # FIXME: below are not migrated yet.
  /*
    hosts = {
    Thomas = {
      modules = [ nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1 ];
    };
    };
  */
}

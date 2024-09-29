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

        systemBuilder = {
          hosts = {
            Henri = {
              system = "x86_64-linux";
              suites = flake.suites.nixos.wsl
                ++
                (with flake.users; [ root syp ]);
              extraConfig = {
                home-manager.users.syp = { self, ... }: {
                  imports = self.suites.home.wsl;
                  im-select.enable = true;
                };
              };
            };

            Thomas = {
              system = "x86_64-linux";
              suites = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1 ];
            };
          };
          hostModuleDir = ./hosts;

          # modules applied to all* hosts
          nixosModules = loadStrippedAsList ./modules/nixos
            ++
            [
              inputs.agenix.nixosModules.default
              inputs.nixos-wsl.nixosModules.default
            ];
          homeModules = loadStrippedAsList ./modules/home
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
          with flake.profiles.nixos; rec {
            inherit (flake.suites.common) base;

            services = [ zfs docker ];

            # typical use cases
            workstation = base ++ services ++ [ lang-region encfs-automount ];
            server = base ++ services ++ [ lang-region ];
            wsl = base ++ [ lang-region wsl-vscode-remote ];
          };

        flake.suites.home =
          with flake.profiles.home; rec {
            base = [ hm-state-version git fish fzf bat neovim tmux ranger ];

            common-apps = [ apps apps-extra www term zathura ledger dev-secrets ];
            coding = [ dev direnv python ];
            multimedia = [ mpv mpd ];

            linux-config-cli = [ xdg-user-dirs dircolors ];
            linux-config-gui = [ xdg-mime-apps fontconfig gui ];

            # typical use cases
            workstation = base ++ common-apps ++ coding ++ multimedia ++
              linux-config-cli ++ linux-config-gui;
            server = base ++ coding ++ linux-config-cli;
            wsl = base ++ coding ++ linux-config-cli ++
              [ apps zathura dev-secrets ];
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
  };
}

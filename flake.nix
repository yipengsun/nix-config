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
      #
    , git-hooks
      #
    , agenix
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }: {
      imports = [
        # third-party libs
        git-hooks.flakeModule
        #inputs.lite-config.flakeModule

        # devShell
        ./dev.nix

        # local modules
        ./lib/localNixpkgs.nix
      ];

      config = {
        systems = [ "x86_64-linux" "x86_64-darwin" ];

        localNixpkgs = {
          config = {
            allowUnfree = true;
          };

          overlays = [
            agenix.overlays.default
          ];
        };
      };
    });


  inputs = {
    nixpkgs-pointer.url = "github:yipengsun/nixpkgs-pointer";
    nixpkgs.follows = "nixpkgs-pointer/nixpkgs";

    # libs/devShell
    flake-parts.url = "github:hercules-ci/flake-parts";
    haumea.url = "github:nix-community/haumea";
    #lite-config.url = "github:yelite/lite-config";

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

    homeage.url = "github:jordanisaacs/homeage";
    homeage.inputs.nixpkgs.follows = "nixpkgs";

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

      #inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [
            nixos-cn.overlay
            berberman.overlays.default
          ];
        };
        nixpkgs-darwin-stable = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [ ];
        };
        latest = { };
      };

      lib = import ./lib { lib = digga.lib // nixos.lib; };

      sharedOverlays = [
        (final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (lfinal: lprev: {
            our = self.lib;
          });
        })

        nur.overlay
        agenix.overlays.default

        (import ./pkgs)
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          imports = [ (digga.lib.importExportableModules ./global/modules) ];
          modules = [
            { lib.our = self.lib; }
            digga.nixosModules.bootstrapIso
            digga.nixosModules.nixConfig
            home.nixosModules.home-manager
            agenix.nixosModules.age
            nixos-wsl.nixosModules.wsl
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts) ];
        hosts = {
          # set host specific properties here
          NixOS = { };
          Thomas = {
            modules = [ nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1 ];
          };
        };
        importables = rec {
          profiles = digga.lib.rakeLeaves ./global/profiles // {
            users = digga.lib.rakeLeaves ./users;
          };
          suites = with profiles; rec {
            base = [ cachix core users.root ];
            service-common = [ zfs docker printer ];

            # computer types
            laptop = base ++ service-common ++ [ users.syp lang-region-mobile encfs-automount proxy-localhost ];
            wsl = base ++ [ users.syp lang-region-mobile ];
          };
        };
      };

      home = {
        imports = [ (digga.lib.importExportableModules ./local/modules) ];
        modules = [ homeage.homeManagerModules.homeage ];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./local/profiles;
          suites = with profiles; rec {
            base = [ hm-state-version git zsh python neovim tmux ranger ];
            common-apps = [ apps www term ];
            coding = [ dev bat direnv fzf ];
            multimedia = [ mpv mpd ];
            prod = [ hep zathura ledger dev-secrets ];

            # settings
            linux-config-cli = [ xdg-user-dirs dircolors ];
            linux-config-gui = [ xdg-mime-apps fontconfig wm gui ];

            workstation = base ++ common-apps ++ coding ++ multimedia ++ prod ++
              linux-config-cli ++ linux-config-gui;
            server = base ++ coding ++ linux-config-cli;
            wsl = base ++ [ apps-wsl zathura ] ++ coding ++ prod ++ linux-config-cli;
          };
        };

        # Users here can be deployed without a host
        users = {
          dev = { suites, ... }: { imports = suites.server; };
        }; # digga.lib.importers.rakeLeaves ./users/hm;
      };

      homeConfigurations =
        digga.lib.mergeAny
          (digga.lib.mkHomeConfigurations self.darwinConfigurations)
          (digga.lib.mkHomeConfigurations self.nixosConfigurations);
      */
}

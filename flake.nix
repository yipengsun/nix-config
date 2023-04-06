# Based on:
#  https://github.com/divnix/digga/blob/main/examples/devos/flake.nix

{
  description = "A highly structured configuration database.";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs =
    {
      nixpkgs-pointer.url = "github:yipengsun/nixpkgs-pointer";

      # various pointers to official packages
      nixos.follows = "nixpkgs-pointer/nixpkgs";
      latest.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-darwin-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";

      # main framework
      digga.url = "github:divnix/digga";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";
      digga.inputs.deploy.follows = "deploy";

      home.url = "github:nix-community/home-manager";
      home.inputs.nixpkgs.follows = "nixos";

      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "nixos";

      deploy.url = "github:serokell/deploy-rs";
      deploy.inputs.nixpkgs.follows = "nixos";

      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixos";

      # additional stuff
      nur.url = "github:nix-community/NUR";

      nixos-hardware.url = "github:nixos/nixos-hardware";

      nixos-cn.url = "github:nixos-cn/flakes";
      nixos-cn.inputs.nixpkgs.follows = "nixos";

      berberman.url = "github:berberman/flakes";
      berberman.inputs.nixpkgs.follows = "nixos";

      homeage.url = "github:jordanisaacs/homeage";
      homeage.inputs.nixpkgs.follows = "nixos";
    };

  outputs =
    { self
    , digga
    , nixos
      #
    , home
    , darwin
    , deploy
    , agenix
      #
    , nur
      #
    , nixos-hardware
    , nixos-cn
    , berberman
    , homeage
      #
    , ...
    } @ inputs:
    digga.lib.mkFlake
      {
        inherit self inputs;

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
              service-common = [ zfs docker globalconnect printer ];

              # computer types
              laptop = base ++ service-common ++ [ users.syp lang-region-mobile encfs-automount proxy-localhost ];
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
            };
          };

          # Users here can be deployed without a host
          users = {
            dev = { suites, ... }: { imports = suites.server; };
          }; # digga.lib.importers.rakeLeaves ./users/hm;
        };

        devshell = ./shell;

        homeConfigurations =
          digga.lib.mergeAny
            (digga.lib.mkHomeConfigurations self.darwinConfigurations)
            (digga.lib.mkHomeConfigurations self.nixosConfigurations);

        deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };
      };
}

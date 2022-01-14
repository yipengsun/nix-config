{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://nix-community.cachix.org";
  #nixConfig.extra-substituters = "https://nrdxp.cachix.org https://nix-community.cachix.org";
  #nixConfig.extra-trusted-public-keys = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs =
    {
      nixpkgs-pointer.url = "github:yipengsun/nixpkgs-pointer";
      nixos.follows = "nixpkgs-pointer/nixpkgs";
      latest.url = "github:nixos/nixpkgs/nixos-unstable";

      digga.url = "github:divnix/digga";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";
      digga.inputs.deploy.follows = "deploy";

      bud.url = "github:divnix/bud";
      bud.inputs.nixpkgs.follows = "nixos";
      bud.inputs.devshell.follows = "digga/devshell";

      home.url = "github:nix-community/home-manager/release-21.11";
      home.inputs.nixpkgs.follows = "nixos";

      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "nixos";

      deploy.url = "github:input-output-hk/deploy-rs";
      deploy.inputs.nixpkgs.follows = "nixos";

      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixos";

      nvfetcher.url = "github:berberman/nvfetcher";
      nvfetcher.inputs.nixpkgs.follows = "nixos";

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "nixos";

      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs =
    { self
    , digga
    , bud
    , nixos
    , home
    , nixos-hardware
    , nur
    , agenix
    , nvfetcher
    , deploy
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
              nur.overlay
              agenix.overlay
              nvfetcher.overlay
              ./pkgs/default.nix
            ];
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
              bud.nixosModules.bud
            ];
          };

          imports = [ (digga.lib.importHosts ./hosts) ];
          hosts = {
            /* set host specific properties here */
            NixOS = { };
            Thomas = { };
          };
          importables = rec {
            profiles = digga.lib.rakeLeaves ./global/profiles // {
              users = digga.lib.rakeLeaves ./users;
            };
            suites = with profiles; rec {
              base = [ core users.root ];
              laptop = base ++ [ users.syp lang-region-mobile ];
            };
          };
        };

        home = {
          imports = [ (digga.lib.importExportableModules ./local/modules) ];
          modules = [ ];
          importables = rec {
            profiles = digga.lib.rakeLeaves ./local/profiles;
            suites = with profiles; rec {
              base = [ direnv git zsh bat hm-state-version ];
              common-apps = [ apps www zathura xterm alacritty ];
              coding = [ dev ];
              multimedia = [ mpv ];
              work = [ hep ];

              # settings
              linux-config-cli = [ xdg-user-dirs dircolors ];
              linux-config-gui = [ xdg-mime-apps ];

              # for computers with a screen
              workstation = base ++ common-apps ++ coding ++ multimedia ++ work ++
              linux-config-cli ++ linux-config-gui;
            };
          };

          # Users here can be deployed without a host
          users = {
            dev = { suites, ... }: { imports = suites.base ++ suites.coding ++ suites.linux-config-cli; };
          }; # digga.lib.importers.rakeLeaves ./users/hm;
        };

        devshell = ./shell;

        homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

        deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };

        defaultTemplate = self.templates.bud;
        templates.bud.path = ./.;
        templates.bud.description = "bud template";
      }
    //
    {
      budModules = { devos = import ./shell/bud; };
    }
  ;
}

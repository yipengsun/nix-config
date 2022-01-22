{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://nix-community.cachix.org";

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

      nixos-cn.url = "github:nixos-cn/flakes";
      nixos-cn.inputs.nixpkgs.follows = "nixos";

      # a bit redundant here, because this is already exported in nixos-cn
      # but the registry doesn't work too well with devos
      berberman-flakes.url = "github:berberman/flakes";
      berberman-flakes.inputs.nixpkgs.follows = "nixos";

      homeage.url = "github:jordanisaacs/homeage";
      homeage.inputs.nixpkgs.follows = "nixos";
    };

  outputs =
    { self
    , digga
    , bud
    , nixos
    , home
    , nixos-hardware
    , nixos-cn
    , berberman-flakes
    , nur
    , agenix
    , nvfetcher
    , deploy
    , homeage
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
              nixos-cn.overlay
              berberman-flakes.overlay
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
              base = [ cachix core users.root ];
              service-common = [ zfs docker ];

              # computer types
              laptop = base ++ service-common ++ [ users.syp lang-region-mobile encfs-automount ];
            };
          };
        };

        home = {
          imports = [ (digga.lib.importExportableModules ./local/modules) ];
          modules = [ homeage.homeManagerModules.homeage ];
          importables = rec {
            profiles = digga.lib.rakeLeaves ./local/profiles;
            suites = with profiles; rec {
              base = [ hm-state-version git zsh python neovim tmux ];
              common-apps = [ apps www zathura xterm alacritty ];
              coding = [ dev bat direnv fzf ];
              multimedia = [ mpv ];
              work = [ hep ];

              # settings
              linux-config-cli = [ xdg-user-dirs dircolors ];
              linux-config-gui = [ xdg-mime-apps fontconfig wm ];

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

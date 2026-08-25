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
    { flake-parts, haumea, ... }@inputs:
    let
      # helper functions
      stripDefault =
        x:
        if builtins.isAttrs x then
          if x ? default then x.default else builtins.mapAttrs (_: value: stripDefault value) x
        else
          x;

      loadStripped =
        src:
        let
          attrs = haumea.lib.load {
            src = src;
            loader = haumea.lib.loaders.path;
          };
        in
        stripDefault attrs;

      loadStrippedAsList = src: builtins.attrValues (loadStripped src);
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          # third-party libs
          inputs.git-hooks.flakeModule

          # devShell
          ./lib/dev-shell.nix

          # local modules
          ./lib/checks.nix
          ./lib/config-nixpkgs.nix
          ./lib/system-builder.nix
        ];

        config = rec {
          systems = [
            "x86_64-linux"
            "aarch64-darwin"
          ];

          perSystem =
            {
              configNixpkgs,
              lib,
              pkgs,
              ...
            }:
            let
              packages = {
                inherit (pkgs)
                  adate
                  awesomesearch
                  clangd
                  colortest
                  git-author-rewrite
                  receipt-archive
                  ;

                fish-async-prompt = pkgs.fishPlugins.async-prompt;
              }
              // lib.optionalAttrs pkgs.stdenv.isLinux {
                inherit (pkgs)
                  awesome-volume-control
                  tridactyl-native
                  ;

                lain = pkgs.lua53Packages.lain;
              }
              // lib.optionalAttrs pkgs.stdenv.isDarwin {
                inherit (pkgs) tridactyl-native-python;
              };
            in
            {
              inherit packages;
              legacyPackages = configNixpkgs;

              checks = lib.mapAttrs' (name: package: lib.nameValuePair "package-${name}" package) packages;
            };

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
              inputs.llm-agents.overlays.shared-nixpkgs
              flake.overlays.default
            ];
          };

          systemBuilder = {
            hostModuleDir = ./hosts;
            hosts = {
              Henri.system = "x86_64-linux";
              Thomas.system = "x86_64-linux";
              Michael.system = "x86_64-linux";
              Leonardo.system = "aarch64-darwin";
            };

            # modules applied to all hosts
            nixosModules = loadStrippedAsList ./modules/nixos ++ [
              inputs.agenix.nixosModules.default
              inputs.nixos-wsl.nixosModules.default
              inputs.disko.nixosModules.disko
            ];
            darwinModules = [
              inputs.agenix.darwinModules.default
              inputs.mac-app-util.darwinModules.default
              inputs.nix-homebrew.darwinModules.nix-homebrew
            ];
            homeModules = loadStrippedAsList ./modules/home ++ [
              inputs.agenix.homeManagerModules.default
              inputs.mac-app-util.homeManagerModules.default
            ];
          };

          flake.users = loadStripped ./users;
          flake.profiles = loadStripped ./profiles;
          flake.suites = import ./suites.nix { profiles = flake.profiles; };
        };
      }
    );

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
    # mac-app-util.inputs.nixpkgs.follows = "nixpkgs"; # FIXME: can't build with latest nixpkgs

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

    llm-agents.url = "github:numtide/llm-agents.nix";
  };
}

# stolen from `lite-config`:
#   https://github.com/yelite/lite-config
#
# provide a configured nixpkgs (config, overlay, etc) to use in the whole flake

{
  inputs,
  lib,
  ...
}@toplevel:
let
  inherit (lib)
    mkOption
    types
    literalExpression
    ;

  cfg = toplevel.config.configNixpkgs; # shortcut to user config

  # types in config
  typeOverlay = with types; uniq (functionTo (functionTo (lazyAttrsOf unspecified)));
  typeNixpkgsInput = types.addCheck types.attrs (
    nixpkgs: nixpkgs ? outPath && nixpkgs ? lib && nixpkgs.lib ? nixosSystem
  );

  typeLocalNixpkgsOptions = types.submodule {
    options = {
      nixpkgs = mkOption {
        type = typeNixpkgsInput;
        default = inputs.nixpkgs;
        defaultText = literalExpression "inputs.nixpkgs";
        description = ''
          Nixpkgs flake input to use. It must expose `outPath` and
          `lib.nixosSystem`.

          Set this when the desired Nixpkgs input has a different name.
        '';
      };

      config = mkOption {
        default = { };
        type = types.attrs;
        description = ''
          The configuration of the Nix Packages collection.
        '';
        example = literalExpression ''
          { allowUnfree = true; }
        '';
      };

      overlays = mkOption {
        default = [ ];
        type = types.listOf typeOverlay;
        description = ''
          List of overlays to use with the Nix Packages collection.
        '';
        example = literalExpression ''
          [
            inputs.fenix.overlays.default
          ]
        '';
      };
    };
  };
in
{
  options = {
    configNixpkgs = mkOption {
      type = typeLocalNixpkgsOptions;
      default = { };
      description = ''
        Config for local nixpkgs.
      '';
    };
  };

  config = {
    perSystem =
      {
        system,
        ...
      }:
      {
        _file = ./.;
        config =
          let
            rawNixpkgs = cfg.nixpkgs;
            configuredNixpkgs = import rawNixpkgs {
              inherit system;
              config = cfg.config;
              overlays = cfg.overlays;
            };
          in
          {
            _module.args.configNixpkgs = lib.mkOptionDefault configuredNixpkgs;
            _module.args.pkgs = configuredNixpkgs;
          };
      };
  };
}

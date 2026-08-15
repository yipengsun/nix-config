# stolen from `lite-config`:
#   https://github.com/yelite/lite-config
#
# build NixOS/darwin systems

{
  self,
  inputs,
  lib,
  withSystem,
  ...
}@toplevel:
let
  inherit (builtins)
    attrValues
    foldl'
    ;

  inherit (lib)
    mapAttrs
    mkOption
    types
    literalExpression
    recursiveUpdate
    ;

  cfgSupport = toplevel.config.configNixpkgs; # external config options
  cfg = toplevel.config.systemBuilder; # shortcut to user config

  resolveHostModule =
    hostName:
    let
      directoryModule = cfg.hostModuleDir + "/${hostName}/default.nix";
      fileModule = cfg.hostModuleDir + "/${hostName}.nix";
    in
    if builtins.pathExists directoryModule then
      directoryModule
    else if builtins.pathExists fileModule then
      fileModule
    else
      throw ''
        No module found for host `${hostName}`.
        Expected `${toString directoryModule}` or `${toString fileModule}`.
        Set `systemBuilder.hosts.${hostName}.hostModule` to override this lookup.
      '';

  # types in config
  typeHostConfig = types.submodule (
    { name, ... }: {
      options = {
        system = mkOption {
          type = types.enum toplevel.config.systems;
          description = ''
            The system of the host.
          '';
          example = literalExpression ''
            "x86_64-linux"
          '';
        };

        hostModule = mkOption {
          type = types.deferredModule;
          default = resolveHostModule name;
          defaultText = literalExpression ''
            <hostModuleDir>/<hostName>/default.nix or <hostModuleDir>/<hostName>.nix
          '';
          description = ''
            Host module to import. By default, this is resolved from
            {option}`systemBuilder.hostModuleDir` using the host name.
          '';
        };

        suites = mkOption {
          type = types.listOf types.deferredModule;
          default = [ ];
          description = ''
            System suites (NixOS or nix-darwin) to be imported by this host.
          '';
        };

        extraConfig = mkOption {
          type = types.deferredModule;
          default = { };
          description = ''
            Extra config passed to the host.
          '';
        };
      };
    }
  );

  typeSystemBuilderOptions = types.submodule {
    options = {
      hosts = mkOption {
        type = types.attrsOf typeHostConfig;
        default = { };
        description = ''
          Host configurations.
        '';
      };

      hostModuleDir = mkOption {
        type = types.path;
        description = ''
          Directory containing host modules. For each host, the builder checks
          `<hostModuleDir>/<hostName>/default.nix` and then
          `<hostModuleDir>/<hostName>.nix`.
        '';
      };

      nixosModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          NixOS modules to be imported by all NixOS hosts.
        '';
      };

      darwinModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          Darwin modules to be imported by all Darwin hosts.
        '';
      };

      homeModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          Home-manager modules to be imported by all hosts.
        '';
      };
    };
  };

  # helper functions
  errUnsupportedSys = system: throw "System type ${system} not supported.";

  # the actual builder
  systemBuilder =
    hostName: hostConfig:
    withSystem hostConfig.system (
      { pkgs, ... }:
      let
        hostPlatform = pkgs.stdenv.hostPlatform;

        systemModules =
          if hostPlatform.isLinux then
            cfg.nixosModules
          else if hostPlatform.isDarwin then
            cfg.darwinModules
          else
            errUnsupportedSys hostPlatform.system;

        homeManagerFlake = inputs.home-manager;
        homeManagerSystemModule =
          if hostPlatform.isLinux then
            homeManagerFlake.nixosModules.default
          else if hostPlatform.isDarwin then
            homeManagerFlake.darwinModules.default
          else
            errUnsupportedSys hostPlatform.system;

        specialArgs = {
          inherit self inputs hostPlatform;
        };

        computerNameModule = if hostPlatform.isDarwin then { networking.computerName = hostName; } else { };

        modules = [
          hostConfig.hostModule
          {
            _file = ./.;
            nixpkgs.pkgs = pkgs;
            networking.hostName = hostName;
          }
          computerNameModule
        ]
        ++ systemModules
        ++ hostConfig.suites
        ++ [
          homeManagerSystemModule
          {
            _file = ./.;
            home-manager = {
              sharedModules = cfg.homeModules;
              useGlobalPkgs = true;
              extraSpecialArgs = specialArgs;
            };
          }
        ]
        ++ [ hostConfig.extraConfig ];

        # aggregated args
        builderArgs = { inherit specialArgs modules; };
      in
      if hostPlatform.isLinux then
        {
          nixosConfigurations.${hostName} = cfgSupport.nixpkgs.lib.nixosSystem builderArgs;
        }
      else if hostPlatform.isDarwin then
        {
          # NOTE: hard-coded darwin builder
          darwinConfigurations.${hostName} = inputs.nix-darwin.lib.darwinSystem builderArgs;
        }
      else
        errUnsupportedSys hostPlatform.system
    );

  systemAttrset =
    let
      sysConfigAttrsets = attrValues (mapAttrs systemBuilder cfg.hosts);
    in
    foldl' recursiveUpdate { } sysConfigAttrsets;
in
{
  options = {
    systemBuilder = mkOption {
      type = typeSystemBuilderOptions;
      default = { };
      description = ''
        Config for NixOS/Darwin systems.
      '';
    };
  };

  config.flake = systemAttrset;
}

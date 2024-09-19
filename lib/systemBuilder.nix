# stolen from `lite-config`:
#   https://github.com/yelite/lite-config
#
# build NixOS/darwin systems

{ inputs
, lib
, withSystem
, ...
} @ toplevel:
let
  inherit (builtins)
    attrValues
    foldl'
    length
    ;

  inherit (lib)
    mapAttrs
    mkOption
    types
    literalExpression
    recursiveUpdateUntil
    ;


  cfgSupport = toplevel.config.localNixpkgs; # external config options
  cfg = toplevel.config.systemBuilder; # shortcut to user config


  # types in config
  typeHostConfig = types.submodule {
    options = {
      system = mkOption {
        type = types.str;
        description = ''
          The system of the host.
        '';
        example =
          literalExpression
            ''
              "x86_64-linux"
            '';
      };

      systemSuites = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          System suites (NixOS or nix-darwin) to be imported by this host.
        '';
      };

      homeSuites = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          Home suites to be imported by this host.
        '';
      };
    };
  };

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
          The directory that contains host modules. Module at
          `''${hostMouduleDir}/''${hostName}` will be imported in
          the configuration of host `hostName` by default.

          The host module used by a host can be overridden in
          {option}`lite-config.hosts.<hostName>.hostModule`.
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
          Home modules to be imported by all hosts.
        '';
      };
    };
  };


  # helper functions
  errUnsupportedSys = system: throw "System type ${system} not supported.";


  # the actual builder
  systemBuilder = hostName: hostConfig:
    withSystem hostConfig.system ({ pkgs, ... }:
      let
        hostPlatform = pkgs.stdenv.hostPlatform;
        hostModule = "${cfg.hostModuleDir}/${hostName}";

        systemModules =
          if hostPlatform.isLinux then cfg.nixosModules
          else if hostPlatform.isDarwin then cfg.darwinModules
          else errUnsupportedSys hostPlatform.system;

        homeManagerFlake = inputs.home-manager;
        homeManagerSystemModule =
          if hostPlatform.isLinux then homeManagerFlake.nixosModules.default
          else if hostPlatform.isDarwin then homeManagerFlake.darwinModules.default
          else errUnsupportedSys hostPlatform.system;

        specialArgs = {
          inherit inputs hostPlatform;
        };

        modules = [
          hostModule
          {
            _file = ./.;
            nixpkgs.pkgs = pkgs;
            networking.hostName = hostName;
          }
        ]
        ++ systemModules ++ hostConfig.systemSuites
        ++
        [
          homeManagerSystemModule
          {
            _file = ./.;
            home-manager = {
              sharedModules = cfg.homeModules ++ hostConfig.homeSuites;
              useGlobalPkgs = true;
              extraSpecialArgs = specialArgs;
            };
          }
        ];

        # aggregated args
        builderArgs = { inherit specialArgs modules; };
      in
      if hostPlatform.isLinux
      then {
        nixosConfigurations.${hostName} = cfgSupport.nixpkgs.lib.nixosSystem builderArgs;
      }
      else if hostPlatform.isDarwin
      then {
        # NOTE: hard-coded darwin builder
        darwinConfigurations.${hostName} = inputs.nix-darwin.lib.darwinSystem builderArgs;
      }
      else errUnsupportedSys hostPlatform.system);

  systemAttrset =
    let
      mergeSysConfig = a: b: recursiveUpdateUntil (path: _: _: (length path) > 2) a b;
      sysConfigAttrsets = attrValues (mapAttrs systemBuilder cfg.hosts);
    in
    foldl' mergeSysConfig { } sysConfigAttrsets;
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


  config = {
    flake = systemAttrset;
  };
}

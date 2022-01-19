{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.xinit.windowManager.awesome;
  awesome = cfg.package;

  getLuaPath = lib: dir: "${lib}/${dir}/lua/${cfg.luaPackages.lua.luaversion}";
  makeSearchPath = lib.concatMapStrings (path:
    " --search ${getLuaPath path "share"}"
    + " --search ${getLuaPath path "lib"}");

  awesomeCmd = "${awesome}/bin/awesome ${makeSearchPath cfg.luaModules}";
in

{
  options = {
    xinit.windowManager.awesome = {
      enable = mkEnableOption "Awesome window manager.";

      package = mkOption {
        type = types.package;
        default = pkgs.awesome;
        defaultText = literalExpression "pkgs.awesome";
        description = "Package to use for running the Awesome WM.";
      };

      luaPackages = mkOption {
        type = types.attrsOf types.package;
        default = pkgs.luaPackages;
        defaultText = literalExpression "pkgs.lua.pkgs";
        description = "Package to Lua packages.";
      };

      luaModules = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of lua packages available for being
          used in the Awesome configuration.
        '';
        example = literalExpression "[ luaPackages.vicious ]";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (hm.assertions.assertPlatform "xinit.windowManager.awesome" pkgs
        platforms.linux)
    ];

    home.packages = [ awesome ];

    xinit.windowManagerCmd = awesomeCmd;
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfgXinit = config.xinit;
  cfgAwesome = config.xinit.windowManager.awesome;

  awesome = cfgAwesome.package;

  getLuaPath = lib: dir: "${lib}/${dir}/lua/${pkgs.luaPackages.lua.luaversion}";
  makeSearchPath = lib.concatMapStrings (path:
    " --search ${getLuaPath path "share"}"
    + " --search ${getLuaPath path "lib"}");

  envVarsStr = config.lib.zsh.exportAll cfgXinit.envVars;
in

{
  options = {
    xinit = {
      envVars = mkOption {
        type = types.attrs;
        default = { };
        description = "List of ENV vars, with name and value";
      };

      initExtra = mkOption {
        type = types.lines;
        default = "";
        description = "Extra shell commands to run during initialization.";
      };
    };

    xinit.windowManager.awesome = {
      enable = mkEnableOption "Awesome window manager.";

      package = mkOption {
        type = types.package;
        default = pkgs.awesome;
        defaultText = literalExpression "pkgs.awesome";
        description = "Package to use for running the Awesome WM.";
      };

      luaModules = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of lua packages available for being
          used in the Awesome configuration.
        '';
        example = literalExpression "[ pkgs.luaPackages.vicious ]";
      };
    };
  };

  config = mkIf cfgAwesome.enable {
    assertions = [
      (hm.assertions.assertPlatform "xinit.windowManager.awesome" pkgs
        platforms.linux)
    ];

    home.packages = [ awesome ];

    home.file.".xinitrc".text = ''
      # load X settings
      if [ -f $HOME/.Xdefaults ]; then
        xrdb $HOME/.Xdefaults
      fi

      # export ENV vars
      ${envVarsStr}

      # extra commands
      ${cfgXinit.initExtra}

      # start awesome window manager
      ${awesome}/bin/awesome ${makeSearchPath cfgAwesome.luaModules}
    '';
  };
}

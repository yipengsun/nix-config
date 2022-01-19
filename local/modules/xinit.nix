{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.xinit;
  envVarsStr = config.lib.zsh.exportAll cfg.envVars;
in

{
  options = {
    xinit = {
      enable = mkEnableOption "Enable xinit.";

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

      windowManagerCmd = mkOption {
        type = types.str;
        default = "xterm";
        description = "Specify window manager to run";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.xorg.xinit ];

    home.file.".xinitrc".text = ''
      #!/bin/sh

      # load X settings
      if [ -f $HOME/.Xdefaults ]; then
        xrdb $HOME/.Xdefaults
      fi

      # export ENV vars
      ${envVarsStr}

      # extra commands
      ${cfg.initExtra}

      # start wm
      ${cfg.windowManagerCmd}
    '';
  };
}

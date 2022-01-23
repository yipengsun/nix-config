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

      requiredFiles = mkOption {
        type = types.listOf types.str;
        default = [ "~/.xinitrc" ];
        description = "Specify files required to exist before running the rest of the script";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.xorg.xinit ];

    home.file.".xinitrc".text = ''
      #!/bin/sh

      # Check required files to exist or block indefinitely
      # This can be quite dangerous
      for file in ${concatStringsSep " " cfg.requiredFiles}; do
        while true; do
          if [ -f $file ]; then
            break
          fi
          sleep 0.05  # don't pull the disk too hard
        done
      done

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

# stolen from:
#   https://github.com/NixOS/nixpkgs/issues/235345#issuecomment-1586233679
#   https://github.com/NixOS/nixpkgs/issues/235345#issuecomment-1622892967
# this needs to be a system-level service, because 'network-online.target' is unavailable to user!
{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.services.maestral;
in
{
  options.services.maestral = {
    enable = mkEnableOption "enable Maestral, a open-source Dropbox client.";
    user = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${cfg.user}.home.packages = [ pkgs.maestral ];

    systemd.services."maestral@${cfg.user}" = {
      description = "Maestral - a open-source Dropbox client";

      unitConfig = rec {
        After = [
          "network-online.target"
        ];
        Requires = After;

        ConditionPathExists = [
          "${config.users.users.${cfg.user}.home}/.config/maestral/maestral.ini"
        ];
      };

      serviceConfig = {
        ExecStart = "${pkgs.maestral}/bin/maestral start --foreground";
        ExecStop = "${pkgs.maestral}/bin/maestral stop";
        Nice = 10;
        Restart = "on-failure";
        User = cfg.user;
        Group = config.users.users.${cfg.user}.group;
        WorkingDirectory = "~";
      };
    };
  };
}

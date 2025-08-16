# stolen from:
#   https://github.com/NixOS/nixpkgs/issues/235345#issuecomment-1586233679
#   https://github.com/NixOS/nixpkgs/issues/235345#issuecomment-1622892967
# this needs to be a system-level service, because 'network-online.target' is unavailable to user!
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.maestral;

  userHome = config.users.users.${cfg.user}.home;
  userUid = builtins.toString config.users.users.${cfg.user}.uid;
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
      wantedBy = [ "multi-user.target" ];

      environment = {
        XDG_RUNTIME_DIR = "${userHome}/.cache";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${userUid}/bus";
      };

      unitConfig = rec {
        After = [
          "network-online.target"
        ];
        Requires = After;
        RequiresMountsFor = config.users.users.${cfg.user}.home;

        ConditionPathExists = [
          "${userHome}/.config/maestral/maestral.ini"
        ];
      };

      serviceConfig = {
        Type = "notify";

        ExecStart = "${pkgs.maestral}/bin/maestral start --foreground";
        ExecStop = "${pkgs.maestral}/bin/maestral stop";

        Nice = 10;
        Restart = "on-failure";
        RestartSec = "5s";

        User = cfg.user;
        Group = config.users.users.${cfg.user}.group;
        WorkingDirectory = "~";
      };
    };
  };
}

# stolen from:
#   https://github.com/NixOS/nixpkgs/issues/235345#issuecomment-1586233679
#   https://github.com/NixOS/nixpkgs/issues/235345#issuecomment-1622892967
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
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.maestral ];

    systemd.user.services.maestral = {
      Unit = rec {
        Description = "Maestral - a open-source Dropbox client";

        After = [
          "graphical-session.target"
        ];
        Requires = After;

        ConditionPathExists = [
          "${config.xdg.configHome}/maestral/maestral.ini"
        ];
      };

      Service = {
        Type = "notify";

        ExecStart = "${pkgs.maestral}/bin/maestral start --foreground";
        ExecStop = "${pkgs.maestral}/bin/maestral stop";

        Nice = 10;
        Restart = "on-failure";
        RestartSec = "5s";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

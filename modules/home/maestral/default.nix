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
          "network.target"
        ];
        Requires = After;

        ConditionUser = "!@system";
      };

      Service = {
        ExecStart = "${pkgs.maestral}/bin/maestral start --foreground";
        ExecStop = "${pkgs.maestral}/bin/maestral stop";
        Nice = 10;
        Restart = "on-failure";
      };
    };
  };
}

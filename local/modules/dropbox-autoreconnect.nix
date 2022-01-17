{ config, lib, pkgs, ... }:

with lib;

# based on home-manager's official dropbox service
let
  cfg = config.services.dropbox-autoreconnect;
  baseDir = ".dropbox-hm";
  dropboxCmd = "${pkgs.dropbox-cli}/bin/dropbox";
  homeBaseDir = "${config.home.homeDirectory}/${baseDir}";
in
{
  meta.maintainers = [ maintainers.eyjhb ];

  options = {
    services.dropbox-autoreconnect.enable = mkEnableOption "Dropbox daemon";
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.dropbox-autoreconnect" pkgs
        lib.platforms.linux)
    ];

    home.packages = [ pkgs.dropbox-cli ];

    systemd.user.services.dropbox-autoreconnect = {
      Unit = { Description = "dropbox"; };

      Install = { WantedBy = [ "default.target" ]; };

      Service = {
        Environment = [ "HOME=${homeBaseDir}" ];

        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;

        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStop = "${pkgs.coreutils}/bin/kill -HUP $MAINPID && ${dropboxCmd} stop";
        ExecStart = toString (pkgs.writeShellScript "dropbox-start" ''
          # ensure we have the dirs we need
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir $VERBOSE_ARG -p \
            ${homeBaseDir}/{.dropbox,.dropbox-dist,Dropbox}

          # get the dropbox bins if needed
          if [[ ! -f $HOME/.dropbox-dist/VERSION ]]; then
            ${pkgs.coreutils}/bin/yes | ${dropboxCmd} update
          fi

          # start dropbox initially
          ${dropboxCmd} start

          # monitor if we are online
          LC_ALL=C nmcli monitor | \
            while read -r line
              do
                if [[ "$line" == "Connectivity is now 'limited'" ]]; then
                  ${dropboxCmd} stop
                elif [[ "$line" == "Connectivity is now 'full'" ]]; then
                  ${dropboxCmd} start
                fi
              done
        '');
      };
    };
  };
}

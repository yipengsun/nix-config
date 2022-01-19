{ config, lib, pkgs, ... }:

with lib;

# based on home-manager's official dropbox service
let
  cfg = config.services.dropbox-autoreconnect;
  baseDir = ".dropbox-hm";
  homeBaseDir = "${config.home.homeDirectory}/${baseDir}";
  dropboxCmd = "HOME=${homeBaseDir} ${pkgs.dropbox-cli}/bin/dropbox";

  dropboxScript = pkgs.writeScriptBin "dropbox-autoreconnect" ''
    #!${pkgs.bash}/bin/bash

    # ensure we have the dirs we need
    ${pkgs.coreutils}/bin/mkdir -p \
      ${homeBaseDir}/{.dropbox,.dropbox-dist,Dropbox}

    # get the dropbox bins if needed
    if [[ ! -f $HOME/.dropbox-dist/VERSION ]]; then
      ${pkgs.coreutils}/bin/yes | ${dropboxCmd} update
    fi

    # first check if we are online
    nm-online
    isOnline=$?

    if [ $isOnline -eq 0 ]; then
      ${dropboxCmd} start
    fi

    # monitor if we are online
    LC_ALL=C nmcli monitor | \
      while read -r line
        do
          if [[ "$line" == "Connectivity is now 'limited'" ]]; then
            echo "Device now offline, stop dropbox..."
            ${dropboxCmd} stop
          elif [[ "$line" == "Connectivity is now 'full'" ]]; then
            echo "Device is back online, start dropbox..."
            ${dropboxCmd} start
          fi
        done
  '';
in
{
  options = {
    services.dropbox-autoreconnect.enable = mkEnableOption "Dropbox launched from xinitrc";
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.dropbox-autoreconnect" pkgs
        lib.platforms.linux)
    ];

    home.packages = [ dropboxScript pkgs.dropbox-cli ];

    xinit.initExtra = "${dropboxScript}/bin/dropbox-autoreconnect &";
  };
}

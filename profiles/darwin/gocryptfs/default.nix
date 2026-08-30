{ lib, pkgs, ... }:
let
  user = "syp";
  homeDir = "/Users/${user}";
  cipherDir = "${homeDir}/Dropbox/data";
  mountDir = "${homeDir}/data";
  keychainService = "nix-config-gocryptfs-data";

  readPassword = pkgs.writeShellApplication {
    name = "read-gocryptfs-data-password";
    text = ''
      exec /usr/bin/security find-generic-password \
        -a ${lib.escapeShellArg user} \
        -s ${lib.escapeShellArg keychainService} \
        -w
    '';
  };

  mountData = pkgs.writeShellApplication {
    name = "mount-gocryptfs-data";
    runtimeInputs = [ pkgs.gnugrep ];
    text = ''
      if /sbin/mount | grep -Fq ${lib.escapeShellArg " on ${mountDir} "}; then
        exit 0
      fi

      if [[ ! -f ${lib.escapeShellArg "${cipherDir}/gocryptfs.conf"} ]]; then
        exit 0
      fi

      if ! /usr/bin/security find-generic-password \
        -a ${lib.escapeShellArg user} \
        -s ${lib.escapeShellArg keychainService} \
        >/dev/null 2>&1; then
        exit 0
      fi

      /bin/mkdir -p ${lib.escapeShellArg mountDir}

      exec ${lib.getExe' pkgs.gocryptfs "gocryptfs"} \
        -fg \
        -q \
        -extpass ${lib.getExe readPassword} \
        ${lib.escapeShellArg cipherDir} \
        ${lib.escapeShellArg mountDir}
    '';
  };

  # Run this once after activating the profile. The login Keychain is unlocked
  # by the macOS login, so subsequent mounts do not need another password.
  setPassword = pkgs.writeShellApplication {
    name = "set-gocryptfs-data-password";
    text = ''
      exec /usr/bin/security add-generic-password \
        -U \
        -a ${lib.escapeShellArg user} \
        -s ${lib.escapeShellArg keychainService} \
        -l ${lib.escapeShellArg "gocryptfs ~/Dropbox/data"} \
        -T /usr/bin/security \
        -w
    '';
  };
in
{
  # gocryptfs itself is available in nixpkgs on Darwin, but mounting requires
  # the privileged macFUSE system extension.
  homebrew.casks = [ "macfuse" ];

  environment.systemPackages = [
    pkgs.gocryptfs
    mountData
    setPassword
  ];

  home-manager.users.${user}.launchd.agents.gocryptfs-data = {
    enable = true;
    config = {
      ProgramArguments = [ (lib.getExe mountData) ];
      ProcessType = "Background";
      RunAtLoad = true;
      StartInterval = 30;
      ThrottleInterval = 30;
      StandardErrorPath = "${homeDir}/Library/Logs/gocryptfs-data.log";
      StandardOutPath = "${homeDir}/Library/Logs/gocryptfs-data.log";
    };
  };
}

{ ... }:
let
  # to workaround a WSL bug. see:
  #  https://github.com/microsoft/WSL/issues/10205#issuecomment-1620605535
  #  https://github.com/microsoft/WSL/issues/8842
  #  https://github.com/nix-community/NixOS-WSL/issues/375#issuecomment-2346390863
  workaround =
    ''
      set TMP_FILE /tmp/1000-wsl-systemd-user-workaround

      # Wait until systemd finalizes bootup
      while not test -S /run/dbus/system_bus_socket
          sleep 1
      end

      # Check if "/run/user/1000/bus" exists
      if test -e /run/user/1000/bus
          exit 0
      end

      # Check if TMP_FILE exists
      if test -e $TMP_FILE
          echo "$TMP_FILE exists"
          exit 0
      end

      # If neither condition is true, restart the session
      touch $TMP_FILE
      sudo systemctl restart user@1000.service
      export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/1000/bus'
      exec sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS --user syp fish
    '';
in
{
  programs.fish.loginShellInit = workaround;
}

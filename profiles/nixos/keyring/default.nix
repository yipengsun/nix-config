{ pkgs, ... }: {
  services.gnome.gnome-keyring.enable = true;

  services.dbus.packages = [ pkgs.gcr ]; # pin entry from GNOME
  # ^this option should be in sync with that in "passwd-mgr"
}

{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;

  services.dbus.packages = [ (pkgs.gcr_3 or pkgs.gcr) ]; # FIXME: Drop the gcr fallback once the nixpkgs pin provides gcr_3.
  # ^this option should be in sync with that in "passwd-mgr"
}

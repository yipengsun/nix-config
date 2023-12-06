{ profiles, ... }: {
  imports = [
    # profiles.networking
    profiles.core
    profiles.users.root # make sure to configure ssh keys
  ];

  boot.loader.systemd-boot.enable = true;

  # will be overridden by the bootstrapIso instrumentation
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };
}

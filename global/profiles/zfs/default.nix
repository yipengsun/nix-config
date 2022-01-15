{
  services.zfs.trim.enable = true; # trim SSD periodically
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 3;
    monthly = 6;
  };
}

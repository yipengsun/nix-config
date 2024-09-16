{
  services.zfs.trim.enable = true; # trim SSD periodically
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 1;
    daily = 1;
    weekly = 1;
    monthly = 1;
  };
}

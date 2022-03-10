{
  services.zfs.trim.enable = true; # trim SSD periodically
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 3;
    daily = 3;
    weekly = 2;
    monthly = 2;
  };
}

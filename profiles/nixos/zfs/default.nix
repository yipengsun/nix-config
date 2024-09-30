{
  services.zfs.trim.enable = true; # trim SSD periodically
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 1;
    hourly = 1;
    daily = 1;
    weekly = 2;
    monthly = 2;
  };
}

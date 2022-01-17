{ config, ... }:
{
  services.dropbox-autoreconnect = {
    enable = true;
    #path = "${config.home.homeDirectory}/.sync/Dropbox";
  };
}

{ config, ... }:
{
  home.file.".sync/.keep".text = "";

  services.dropbox = {
    enable = false;
    #path = "${config.home.homeDirectory}/.sync/Dropbox";
  };
}

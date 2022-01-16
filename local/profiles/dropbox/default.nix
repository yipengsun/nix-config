{ config, ... }:
{
  home.file.".sync/.keep".text = "";

  services.dropbox = {
    enable = true;
    path = "${config.home.homeDirectory}/.sync/Dropbox";
  };
}

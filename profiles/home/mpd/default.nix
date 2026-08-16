{ config, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/misc/audios";
    playlistDirectory = "${config.home.homeDirectory}/sync/dropbox/playlists";
  };

  programs.ncmpcpp = {
    enable = true;

    bindings = [
      {
        key = "j";
        command = "scroll_down";
      }
      {
        key = "k";
        command = "scroll_up";
      }
      {
        key = "G";
        command = "move_home";
      }
    ];
  };
}

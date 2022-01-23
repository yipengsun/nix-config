{ config, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = /home/syp/misc/audios;
    playlistDirectory = /home/syp/sync/dropbox/playlists;
  };

  programs.ncmpcpp = {
    enable = true;

    bindings = [
      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }
      { key = "G"; command = "move_home"; }
    ];
  };
}

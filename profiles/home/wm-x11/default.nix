{
  awesome-wm-config.enable = true;
  fcitx5-config.enable = true;

  # FIXME: dropbox doesn't work on unstable nixpkgs as of 2024-09-29
  #services.dropbox.enable = true;
  services.maestral.enable = true;

  services.picom = {
    enable = true;
    shadow = true;
    shadowExclude = [
      "_NET_WM_WINDOW_TYPE@:32a * = '_NET_WM_WINDOW_TYPE_DOCK'"
    ];
  };
}

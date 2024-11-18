{
  awesome-wm-config.enable = true;
  fcitx5-config.enable = true;

  # FIXME: dropbox doesn't work on unstable nixpkgs as of 2024-09-29
  #services.dropbox.enable = true;
  services.maestral.enable = true;

  services.picom = {
    enable = true;
    shadow = true;
    backend = "glx";

    shadowExclude = [
      "_GTK_FRAME_EXTENTS@:c"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
      "class_g = 'Polybar'"
      "override_redirect"
    ];

    # settings = {
    #   shadow-ignore-shaped = true;
    # };

    wintypes = {
      dock = { shadow = false; };
    };
  };
}

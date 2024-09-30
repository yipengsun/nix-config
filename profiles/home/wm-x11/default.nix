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
      "window_type *= 'menu' && name ~= 'Firefox$'"
      "window_type *= 'utility' && name ~= 'Firefox$'"
    ];

    wintypes = {
      dock = { shadow = false; };
    };
  };
}

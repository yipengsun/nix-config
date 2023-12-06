{ home
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    root # CERN ROOT
    zoom-us # ZOOM for meeting
  ];
}

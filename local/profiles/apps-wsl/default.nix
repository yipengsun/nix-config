{ home
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    # utilities
    adate
    bashmount # mount disk via a TUI
    bc # the calculator
    colortest
    nix-index # use w/ nix-locate

    # X11 utilities
    xorg.xrdb
    xorg.xev
    xorg.xmodmap
    glxinfo

    # document
    pdfgrep
    imagemagick
    ghostscript # for pdf -> png conversion
    pdftk

    # multimedia
    sxiv # picture viewer
  ];
}

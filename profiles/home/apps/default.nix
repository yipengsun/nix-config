{ home
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    # utilities
    adate
    bashmount # mount disk via a TUI
    colortest
    nix-index # use w/ nix-locate

    # document
    pdfgrep
    imagemagick
    ghostscript # for pdf -> png conversion
    pdftk

    # multimedia
    sxiv # picture viewer
  ];
}

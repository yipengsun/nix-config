{ pkgs, ... }: {
  home.packages = with pkgs; [
    # utilities
    adate
    bashmount # mount disk via a TUI
    colortest

    # document
    pdfgrep
    imagemagick
    ghostscript # for pdf -> png conversion
    pdftk

    # multimedia
    sxiv # picture viewer
  ];
}

{ home, pkgs, ... }:
{
  home.packages = with pkgs; [
    # utilities
    ledger # CLI accounting tool
    bashmount # mount disk via a TUI
    bc # the calculator
    scrot # screen shot
    #pychrom

    # Audio utilities
    pamixer # To make adj. volume w/ hotkey work
    pulsemixer # ncurses PA mixer

    # X11 utilities
    xorg.xrdb
    xorg.xev
    xorg.xmodmap
    xclip
    arandr
    glxinfo

    # document
    pdfgrep
    #pdftk
    #imagemagick

    # multimedia
    sxiv # picture viewer
  ];
}

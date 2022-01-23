{ home, pkgs, ... }:
{
  home.packages = with pkgs; [
    # utilities
    adate
    ledger # CLI accounting tool
    bashmount # mount disk via a TUI
    bc # the calculator
    scrot # screen shot
    #pychrom

    # Audio utilities
    pulsemixer # ncurses PA mixer

    # X11 utilities
    xorg.xrdb
    xorg.xev
    xorg.xmodmap
    arandr
    glxinfo

    # document
    pdfgrep
    #pdftk
    #imagemagick

    # multimedia
    sxiv # picture viewer

    # chat
    nixos-cn.wine-wechat
  ];
}

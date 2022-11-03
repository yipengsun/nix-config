{ home, pkgs, ... }:
{
  home.packages = with pkgs; [
    # utilities
    adate
    bashmount # mount disk via a TUI
    bc # the calculator
    scrot # screen shot
    neofetch
    colortest
    nix-index # use w/ nix-locate
    dmidecode # hardware info
    #hashutils

    # Audio utilities
    pulsemixer # ncurses PA mixer

    # X11 utilities
    xorg.xrdb
    xorg.xev
    xorg.xmodmap
    arandr
    glxinfo
    #pychrom

    # document
    pdfgrep
    imagemagick
    ghostscript # for pdf -> png conversion
    tikzit # draw tikz diagrams with a GUI
    wpsoffice
    krop # crop figures from pdf
    pdftk
    pdfchain

    # multimedia
    sxiv # picture viewer

    # chat
    nixos-cn.wine-wechat

    # git utils
    #git-author-rewrite
  ];
}

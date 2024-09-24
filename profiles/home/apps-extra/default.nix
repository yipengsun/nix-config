{ home
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    # utilities
    scrot # screen shot
    neofetch
    colortest
    dmidecode # hardware info

    # X11 utilities
    xorg.xrdb
    xorg.xev
    xorg.xmodmap
    arandr
    glxinfo
    #pychrom

    # document
    krop # crop figures from pdf

    # chat
    wechat-uos

    # git utils
    #git-author-rewrite

    # misc
    #nur.repos.linyinfeng.wemeet
    #nur.repos.xddxdd.baidupcs-go
  ];
}

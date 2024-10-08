{ pkgs, ... }: {
  home.packages = with pkgs; [
    # utilities
    neofetch
    colortest
    dmidecode # hardware info

    # X11 utilities
    xorg.xrdb
    xorg.xev
    xorg.xmodmap
    arandr
    glxinfo
    xcolor # screen color picker

    # document
    krop # crop figures from pdf
    satty # screenshot annotation

    # git utils
    #git-author-rewrite

    # misc
    #nur.repos.linyinfeng.wemeet
    #nur.repos.xddxdd.baidupcs-go
  ];
}

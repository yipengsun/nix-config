{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # utilities
    fastfetch
    colortest
    dmidecode # hardware info

    # X11 utilities
    xrdb
    xev
    xmodmap
    arandr
    mesa-demos # glxinfo
    xcolor # screen color picker

    # document
    # krop # disabled because its PyPDF2 dependency is marked insecure
    satty # screenshot annotation

    # git utils
    #git-author-rewrite

    # misc
    #nur.repos.linyinfeng.wemeet
    #nur.repos.xddxdd.baidupcs-go
  ];
}

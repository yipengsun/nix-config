{ home, pkgs, ... }:
{
  home.packages = with pkgs; [
    git-annex
    universal-ctags

    # language servers
    ccls
    texlab
    rnix-lsp
  ];
}

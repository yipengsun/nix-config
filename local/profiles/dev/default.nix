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

  # linter config
  xdg.configFile."flake8".text = builtins.readFile ./flake8;
  xdg.configFile."pylintrc".text = builtins.readFile ./pylintrc;
}

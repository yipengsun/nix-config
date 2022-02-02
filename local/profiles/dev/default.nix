{ home, pkgs, ... }:
{
  home.packages = with pkgs; [
    git-annex
    universal-ctags
    nixpkgs-review # for reviewing nixpkgs pr
    nixpkgs-fmt # code formatter
  ];

  # linter config
  # flake8 4.0+ no longer support a user-wide config!
  #xdg.configFile."flake8".text = builtins.readFile ./flake8;
  xdg.configFile."pylintrc".text = builtins.readFile ./pylintrc;
}

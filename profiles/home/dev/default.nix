{ home
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    cachix
    git-annex
    universal-ctags
    nixpkgs-review # for reviewing nixpkgs pr
    nixpkgs-fmt # code formatter
    nix-tree # view dependency as a tree
    black # python code formatter
    #jetbrains.clion
    gh # github cli tool
    nix-tree
  ];

  # linter config
  # flake8 4.0+ no longer support a user-wide config!
  #xdg.configFile."flake8".text = builtins.readFile ./flake8;
  xdg.configFile."pylintrc".text = builtins.readFile ./pylintrc;
}

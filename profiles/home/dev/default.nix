{ home
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    git-annex

    universal-ctags

    cachix

    nixpkgs-review # for reviewing nixpkgs pr
    nixpkgs-fmt # code formatter
    nix-tree # view dependency as a tree

    gh # github cli tool

    root # for c++ dev
  ];

  # linter config
  #xdg.configFile."pylintrc".text = builtins.readFile ./pylintrc;
}

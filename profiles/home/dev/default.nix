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
    #jetbrains.clion
    gh # github cli tool
    nix-tree
  ];

  # linter config
  #xdg.configFile."pylintrc".text = builtins.readFile ./pylintrc;
}

{ pkgs, ... }:
let
  # probably no longer needed after git-annex 10.20240430
  rclone-git-annex = pkgs.writeShellScriptBin "git-annex-remote-rclone-builtin" ''
    ${pkgs.rclone}/bin/rclone "$@"
  '';
in
{
  home.packages = with pkgs; [
    git-annex
    rclone # special dropbox remote for git-annex

    cachix

    nixpkgs-review # for reviewing nixpkgs pr
    nixpkgs-fmt # code formatter
    nix-tree # view dependency as a tree

    gh # github cli tool

    root # for c++ dev
  ];

  # linter config
  xdg.configFile."pylintrc".text = builtins.readFile ./pylintrc;

  # cgdb config
  home.file.".cgdb/cgdbrc".text = ''
    set wso=vertical
  '';
}

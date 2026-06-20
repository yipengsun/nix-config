{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      git-annex
      rclone # special dropbox remote for git-annex

      pax-utils
      cachix

      nixpkgs-review # for reviewing nixpkgs pr
      nixfmt-tree # code formatter
      nix-tree # view dependency as a tree

      gh # github cli tool

      # LLM agents
      llm-agents.opencode
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      strace
      root # for c++ dev, broken on darwin due to isa-l being broken
    ];

  # linter config
  xdg.configFile."pylintrc".text = builtins.readFile ./pylintrc;

  # cgdb config
  home.file.".cgdb/cgdbrc".text = ''
    set wso=vertical
  '';

  # disable man cache for darwin only
  programs.man.generateCaches = pkgs.lib.mkIf pkgs.stdenv.isDarwin false;
}

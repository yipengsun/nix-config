{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      g = "git";
      top = "btm"; # bottom
      df = "df -hT";
      du = "du -hs";

      # nix
      ns = "nix search --no-update-lock-file";
      nepl = "nix repl '<nixpkgs>'";
      nsysgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      nstrayroots = ''nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory)"'';

      # frequently used dirs
      "~downloads" = "$HOME/downloads";
      "~dropbox" = "$HOME/sync/dropbox";
      "~talks" = "$HOME/misc/documents/talks";
      "~notes" = "$HOME/misc/documents/personal/notes";
    };

    interactiveShellInit = ''
      # navigate in auto-completion menu, vi-style
      bind h 'if commandline --paging-mode; commandline --function backward-char; else; commandline --insert h; end'
      bind j 'if commandline --paging-mode; commandline --function down-line; else; commandline --insert j; end'
      bind k 'if commandline --paging-mode; commandline --function up-line; else; commandline --insert k; end'
      bind l 'if commandline --paging-mode; commandline --function forward-char; else; commandline --insert l; end'
    '';

    plugins = [
      {
        name = "fish";
        src = pkgs.fetchFromGitHub {
          owner = "pure-fish";
          repo = "pure";
          rev = "28447d2e7a4edf3c954003eda929cde31d3621d2";
          sha256 = "sha256-8zxqPU9N5XGbKc0b3bZYkQ3yH64qcbakMsHIpHZSne4=";
        };
      }
    ];
  };
}

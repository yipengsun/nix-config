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
      nepl = "nix repl --file '<nixpkgs>'";
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

      # expand ... as ../..
      function expand-dot-to-parent-directory-path -d 'expand ... to ../.. etc'
          # get commandline up to cursor
          set -l cmd (commandline --cut-at-cursor)

          # match last line
          switch $cmd[-1]
              case '*..'
                  commandline --insert '/..'
              case '*'
                  commandline --insert '.'
          end
      end

      bind . 'expand-dot-to-parent-directory-path'

      # jump between words with ctrl-j/ctrl-k
      bind \cj backward-word
      bind \ck forward-word
    '';

    plugins = [
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "pure-fish";
          repo = "pure";
          rev = "28447d2e7a4edf3c954003eda929cde31d3621d2";
          sha256 = "sha256-8zxqPU9N5XGbKc0b3bZYkQ3yH64qcbakMsHIpHZSne4=";
        };
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
          sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
    ];
  };
}

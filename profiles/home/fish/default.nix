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

      # configure pure-fish
      set --universal pure_enable_nixdevshell false  # true -> 1 residual char at line start
      set --universal pure_show_prefix_root_prompt true
      set --universal pure_symbol_prefix_root_prompt "root"
      set --universal pure_enable_git_async true
      set --universal pure_enable_single_line_prompt false

      # disable fish greeting
      set --universal fish_greeting
    '';

    plugins = with pkgs.fishPlugins; [
      {
        name = "pure";
        src = pure.src;
      }
      {
        name = "z";
        src = z.src;
      }
      {
        name = "fzf.fish";
        src = fzf-fish.src;
      }
      {
        name = "async-prompt";
        src = async-prompt.src;
      }
    ];
  };
}

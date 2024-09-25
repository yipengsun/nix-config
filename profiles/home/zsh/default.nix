{ pkgs, ... }: {
  home.packages = [ pkgs.zsh-completions ];

  programs.zsh =
    let
      preztoTheme = "pure";
    in
    {
      enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      dirHashes = {
        downloads = "$HOME/downloads";
        dropbox = "$HOME/sync/dropbox";

        # frequently used projects
        talks = "$HOME/misc/documents/talks";
        notes = "$HOME/misc/documents/personal/notes";

        # research projects
        lhcb = "$HOME/misc/researches/lhcb-data_analysis";
        lhcb-hw = "$HOME/misc/researches/lhcb-hardware_related";
        franco = "$HOME/misc/researches/umd-franco";
      };

      shellAliases = {
        # git
        g = "git";

        # internet ip
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        n = "nix";
        ns = "n search --no-update-lock-file";
        nf = "n flake";
        nepl = "n repl '<nixpkgs>'";
        nsysgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        nstrayroots = ''nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory)"'';

        # top
        top = "btm"; # bottom

        # misc.
        df = "df -hT";
        du = "du -hs";

        # dropbox
        dropstart = "HOME=$HOME/.dropbox-hm dropbox start";
        dropstop = "HOME=$HOME/.dropbox-hm dropbox stop";
      };

      initExtra = ''
        # Navigating command line
        bindkey '^J' backward-word
        bindkey '^K' forward-word

        # More familary history search
        autoload history-search-end
        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end history-search-end

        bindkey '^P' history-beginning-search-backward-end
        bindkey '^N' history-beginning-search-forward-end

        # Command line editing
        autoload -U edit-command-line
        zle -N edit-command-line

        bindkey '^\' edit-command-line

        # vi-style movement in auto-completion menu
        zstyle ':completion:*' menu select
        zmodload zsh/complist

        bindkey -M menuselect 'h' vi-backward-char        # left
        bindkey -M menuselect 'k' vi-up-line-or-history   # up
        bindkey -M menuselect 'l' vi-forward-char         # right
        bindkey -M menuselect 'j' vi-down-line-or-history # bottom

        # add 'sudo' to current line
        sudo-command-line() {
          [[ -z $BUFFER ]] && zle up-history
          [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
          zle end-of-line
        }
        zle -N sudo-command-line

        bindkey '\e\e' sudo-command-line

        # Emit OSC 7 for wezterm to consume
        url-encode() {
          local length="''${#1}"
          for (( i = 0; i < length; i++ )); do
            local c="''${1:$i:1}"
            case $c in
              %) printf '%%%02X' "'$c" ;;
              *) printf "%s" "$c" ;;
            esac
          done
        }

        osc7-cwd() {
          printf '\e]7;file://%s%s\a' "$HOSTNAME" "$(url-encode "$PWD")"
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook -Uz chpwd osc7-cwd

        # Run osc7-cwd on zsh startup
        osc7-cwd
      '';

      prezto = {
        enable = true;
        editor.dotExpansion = true;

        prompt.pwdLength = "long";
        prompt.theme = preztoTheme;
      };

      loginExtra = ''
        # Auto start awesome when login at TTY1
        if [ $(id -u) -ne 0 ] && [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
            exec startx
        fi
      '';

      envExtra = ''
        export PATH=$HOME/bin:$PATH
      '';
    };
}

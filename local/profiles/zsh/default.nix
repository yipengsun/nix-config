{
  programs.zsh = {
    enable = true;

    dirHashes = {
      downloads = "$HOME/downloads";
      dropbox = "$HOME/.sync/Dropbox";

      # frequently used projects
      talks = "$HOME/misc/documents/talks";
      notes = "$HOME/misc/documents/personal/notes";

      # research projects
      lhcb = "$HOME/misc/researches/lhcb-data_analysis";
      lhcb-hw = "$HOME/misc/researches/lhcb-hardware_related";
      franco = "$HOME/misc/researches/umd-franco";
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
    '';

    prezto = {
      enable = true;
      editor.dotExpansion = true;

      prompt.pwdLength = "long";
      prompt.theme = "pure";

      syntaxHighlighting.highlighters = [
        "main" "brackets" "pattern" "line" "root"
      ];
    };

    # auto start awesome when login at TTY1
    loginExtra = ''
      if [ $(id -u) -ne 0 ] && [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
          exec startx
      fi
    '';
  };
}

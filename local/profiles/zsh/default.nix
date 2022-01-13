{
  programs.zsh = {
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

    enable = true;

    prezto = {
      enable = true;
      editor.dotExpansion = true;

      prompt.pwdLength = "long";
      prompt.theme = "pure";

      syntaxHighlighting.highlighters = [
        "main" "brackets" "pattern" "line" "root"
      ];

      extraConfig = ''
        bindkey '^P' history-beginning-search-backward-end
        bindkey '^N' history-beginning-search-forward-end
        bindkey '^J' backward-word
        bindkey '^K' forward-word
        bindkey '^\' edit-command-line

        bindkey -M menuselect 'h' vi-backward-char        # left
        bindkey -M menuselect 'k' vi-up-line-or-history   # up
        bindkey -M menuselect 'l' vi-forward-char         # right
        bindkey -M menuselect 'j' vi-down-line-or-history # bottom
      '';
    };

    # auto start awesome when login at TTY1
    loginExtra = ''
      if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
          exec startx
      fi
    '';
  };
}

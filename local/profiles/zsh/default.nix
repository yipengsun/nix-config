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
    enableSyntaxHighlighting = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };

    # auto start awesome when login at TTY1
    loginExtra = ''
      if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
          exec startx
      fi
    '';
  };
}

{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      key_bindings = [
        { key = "Return"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
      ];
      font.size = 6;
      # dracula theme
      colors = {
        primary = {
          background = "#282a36";
          foreground = "#f8f8f2";
          bright_foreground = "#ffffff";
        };
        cursor = {
          text = "#282a36";
          cursor = "#ff5555";
        };
        vi_mode_cursor = {
          text = "CellBackground";
          cursor = "CellForeground";
        };
        search = {
          matches = {
            foreground = "#44475a";
            background = "#50fa7b";
          };
          focused_match = {
            foreground = "#44475a";
            background = "#ffb86c";
          };
          bar = {
            background = "#282a36";
            foreground = "#f8f8f2";
          };
        };
        hints = {
          start = {
            foreground = "#282a36";
            background = "#f1fa8c";
          };
          end = {
            foreground = "#f1fa8c";
            background = "#282a36";
          };
        };
        line_indicator = {
          foreground = "None";
          background = "None";
        };
        selection = {
          text = "CellForeground";
          background = "#44475a";
        };
        normal = {
          black = "#21222c";
          red = "#ff5555";
          green = "#50fa7b";
          yellow = "#f1fa8c";
          blue = "#bd93f9";
          magenta = "#ff79c6";
          cyan = "#8be9fd";
          white = "#f8f8f2";
        };
        bright = {
          black = "#6272a4";
          red = "#ff6e6e";
          green = "#69ff94";
          yellow = "#ffffa5";
          blue = "#d6acff";
          magenta = "#ff92df";
          cyan = "#a4ffff";
          white = "#ffffff";
        };
      };
    };
  };

  home.file.".Xdefaults".text = ''
    ! Fix Alt Key Input
    XTerm*eightBitInput: false
    XTerm*altSendsEscape: true

    ! Fix Shift Key Input
    XTerm*VT100*translations: #override \n\
    Shift <KeyRelease>:insert-seven-bit()

    ! Disable enter fullscreen via a hotkey
    XTerm*fullscreen: never
    XTerm.omitTranslation: fullscreen

    ! Select the whole URL
    xterm*charClass: 33:48,36-47:48,58-59:48,61:48,63-64:48,95:48,126:48

    ! Bell
    XTerm*bellIsUrgent: true

    XTerm*jumpScroll: true
    XTerm*SaveLines: 2000
    XTerm*termName: xterm-256color

    ! Triple click select URI
    XTerm*on3Clicks: regex ([[:alpha:]]+://)?([[:alnum:]!#+,./=?@_~-]|(%[[:xdigit:]][[:xdigit:]]))+

    ! Keybindings
    XTerm.vt100.translations: #override \n\
        Ctrl Shift <Key>C: copy-selection(CLIPBOARD) \n\
        Ctrl Shift <Key>V: insert-selection(CLIPBOARD)

    ! Fonts
    XTerm*fontMenu*fontdefault*Label: Default
    XTerm*faceName: DejaVu Sans Mono
    XTerm*faceSize: 10

    XTerm*scrollbar: no
    *VT100*utf8Title: true

    ! Dracula palette
    *.foreground: #F8F8F2
    *.background: #282A36
    *.color0:     #000000
    *.color8:     #4D4D4D
    *.color1:     #FF5555
    *.color9:     #FF6E67
    *.color2:     #50FA7B
    *.color10:    #5AF78E
    *.color3:     #F1FA8C
    *.color11:    #F4F99D
    *.color4:     #BD93F9
    *.color12:    #CAA9FA
    *.color5:     #FF79C6
    *.color13:    #FF92D0
    *.color6:     #8BE9FD
    *.color14:    #9AEDFE
    *.color7:     #BFBFBF
    *.color15:    #E6E6E6
  '';
}

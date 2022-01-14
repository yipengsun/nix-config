{ home, ... }:
{
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
    XTerm*faceNameDoublesize: WenQuanYi MicroHei Mono
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

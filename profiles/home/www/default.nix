{ config, pkgs, ... }:
let
  preferredTerm = elems:
    with builtins;
    if elems == [ ] then "xterm"
    else if (head elems).pred then (head elems).value
    else preferredTerm (tail elems);

  defaultTerm = preferredTerm [
    { pred = config.programs.wezterm.enable; value = "wezterm"; }
    { pred = config.programs.alacritty.enable; value = "alacritty"; }
  ];

  vim-terminal = pkgs.writeScriptBin "vim-terminal" ''
    ${defaultTerm} -e nvim $1
  '';

  isLinux = pkgs.stdenv.isLinux;
in
{
  # firefox tridactyl-related
  home.packages = [ vim-terminal ];

  home.file.".tridactylrc".text = ''
    """""""""""
    " Generic "
    """""""""""

    set editorcmd vim-terminal

    " Scroll settings
    set smoothscroll true

    " Use default new tab
    set newtab about:blank


    """"""
    " UI "
    """"""

    " Sane hinting mode
    set hintfiltermode vimperator-reflow
    set hintnames numeric

    " Auto hide nav bar
    "guiset_quiet navbar autohide

    " Move hover links to the right
    guiset_quiet hoverlink right


    """"""""""""""""
    " Key bindings "
    """"""""""""""""

    " Scroll down/up
    unbind j,k
    bind j scrollline 5
    bind k scrollline -5

    " Scroll left/right
    bind < scrollpx -50 0
    bind > scrollpx 50 0

    " Move between tabs
    unbind h,l
    bind h tabprev
    bind l tabnext

    " Bookmark prompt
    bind B fillcmdline bmarks
  '';

  programs.firefox = {
    enable = true;
    package = if isLinux then pkgs.firefox else pkgs.firefox-bin;

    nativeMessagingHosts = if isLinux then [ pkgs.tridactyl-native ] else [ ];

    profiles."syp" = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        tridactyl
        ublock-origin
        darkreader # dark theme for all websites
        copy-selection-as-markdown
        i-dont-care-about-cookies
        lastpass-password-manager
        no-pdf-download # open pdf directly instead of asking for download
        offline-qr-code-generator
        private-relay # email aliases by firefox
      ];

      isDefault = true;
      id = 0;
      settings = {
        "browser.startup.homepage" = "https://google.com";
        "browser.bookmarks.showMobileBookmarks" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # to load userChrome.css, etc.
      };
      userChrome = ''
        * {
          font-family: "monospace";
          font-size: 9pt;
        }
      '';
    };
  };

  home.sessionVariables = {
    MOZ_LEGACY_PROFILES = "1";
  };

  programs.chromium = {
    enable = isLinux;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock-origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
    ];
  };
}

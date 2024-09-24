{ pkgs, ... }:
let
  vim-terminal = pkgs.writeScriptBin "vim-terminal" ''
    alacritty -e nvim $1
  '';
in
{
  # firefox tridactyl-related
  home.packages = [
    vim-terminal
  ];

  home.file.".tridactylrc".text = ''
    """""""""""
    " Generic "
    """""""""""

    " Set editorcmd to 'vim-terminal'
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

    nativeMessagingHosts = [ pkgs.tridactyl-native ];

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
          font-family: "DejaVu Sans Mono";
          font-size: 9pt;
        }
      '';
    };
  };

  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock-origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
    ];
  };
}

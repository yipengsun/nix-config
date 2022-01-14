{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = { enableTridactylNative = true; };
    };

    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      tridactyl
      ublock-origin
      unpaywall
      darkreader # dark theme for all websites
      copy-selection-as-markdown
      i-dont-care-about-cookies
      lastpass-password-manager
      no-pdf-download # open pdf directly instead of asking for download
      octotree # github on steroids
      offline-qr-code-generator
      private-relay # email aliases by firefox
      search-by-image
    ];

    profiles."syp" = {
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
}

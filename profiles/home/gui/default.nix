{ pkgs, ... }:
let
  themeName = "Dracula";
in
{
  # NOTE: need to add
  #   programs.dconf.enable = true
  # in nixos settings
  gtk = {
    enable = true;
    font = {
      name = "monospace";
      size = 9;
    };

    iconTheme = {
      name = themeName;
      package = pkgs.dracula-icon-theme;
    };

    theme = {
      name = themeName;
      package = pkgs.dracula-theme;
    };
  };

  qt = {
    enable = true;
    style = {
      name = themeName;
      package = pkgs.dracula-qt5-theme;
    };
  };

  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 48;

    x11.enable = true;
    gtk.enable = true;
  };
}

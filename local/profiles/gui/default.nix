{ pkgs, ... }:
{
  # NOTE: need to add
  #   programs.dconf.enable = true
  # in host settings
  gtk = {
    enable = true;
    font = {
      name = "Dejavu Sans Mono for Powerline";
      size = 9;
    };

    iconTheme = {
      package = pkgs.dracula-theme;
      name = "Dracula";
    };

    theme.name = "Dracula";
  };
}

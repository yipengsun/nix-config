{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      # document
      pdfgrep
      imagemagick
      ghostscript # for pdf -> png conversion
      pdftk
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # utilities
      adate
      bashmount # mount disk via a TUI

      # multimedia
      sxiv # picture viewer
    ];
}

{ pkgs, ... }:
let
  pinentryProgram = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
in
{
  programs.rbw.enable = true;

  programs.rbw.settings = {
    email = "ypsun92@gmail.com";
    lock_timeout = 360; # should be 15 days?
    pinentry = pinentryProgram;
  };
}

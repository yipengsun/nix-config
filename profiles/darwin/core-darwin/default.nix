{ pkgs, lib, ... }:
let
  isDarwinAarch64 = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
in
{
  system.primaryUser = "syp";

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;

    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";

    loginwindow.LoginwindowText = "";

    screencapture.location = "~/Pictures/screenshots";

    screensaver.askForPasswordDelay = 10;

    # always use metric units!! FUCK imperial units!!
    NSGlobalDomain.AppleMetricUnits = 1;

    NSGlobalDomain.AppleICUForce24HourTime = true;

    # so that when holding 'j', no accented versions of j would show up
    # and vs code scrolls down multiple lines
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
  };

  system.startup.chime = false;

  environment.shells = [ pkgs.fish ];

  environment.systemPackages = lib.optionals isDarwinAarch64 [
    pkgs.macmon
  ];

  power = {
    sleep.computer = "never";
    sleep.display = 20; # in minutes
  };
}

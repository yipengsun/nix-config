{ pkgs, ... }:
{
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;

    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";

    loginwindow.LoginwindowText = "";

    screencapture.location = "~/Pictures/screenshots";

    screensaver.askForPasswordDelay = 10;
  };

  system.startup.chime = false;

  environment.shells = [ pkgs.fish ];

  power = {
    sleep.computer = "never";
    sleep.display = 20; # in minutes
  };
}

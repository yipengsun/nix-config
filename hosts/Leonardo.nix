{ self, lib, ... }:
{
  system.stateVersion = 5;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  users.users.syp = {
    name = "syp";
  };


  home-manager.users.syp = { pkgs, ... }: {


    home = {
      #username = lib.mkForce ("syp");
      homeDirectory = lib.mkForce "/Users/syp";
    };

    imports = self.suites.home.darwin;
  };
}

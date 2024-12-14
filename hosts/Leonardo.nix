{ self, lib, ... }:
{
  system.stateVersion = 5;


  #################
  # Darwin config #
  #################

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;

    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";

    loginwindow.LoginwindowText = "";

    screencapture.location = "~/Pictures/screenshots";

    screensaver.askForPasswordDelay = 10;
  };


  #################
  # System config #
  #################

  imports = with self.users; [ syp ];

  users.users.syp = {
    name = "syp";
  };


  ###############
  # User config #
  ###############

  home-manager.users.syp = { pkgs, ... }: {
    home = {
      #username = lib.mkForce ("syp");
      homeDirectory = lib.mkForce "/Users/syp";
    };

    imports = self.suites.home.darwin;
  };
}

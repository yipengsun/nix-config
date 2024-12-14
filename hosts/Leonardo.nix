{ self, lib, pkgs, ... }:
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

  system.startup.chime = false;

  environment.shells = [ pkgs.fish ];

  power = {
    sleep.computer = "never";
    sleep.display = 20; # in minutes
  };

  security.pam.enableSudoTouchIdAuth = true;


  #################
  # System config #
  #################

  imports = self.suites.darwin.base ++ (with self.users; [ syp ]);

  users.users.syp = {
    name = "syp";
  };


  ###############
  # User config #
  ###############

  home-manager.users.syp = { pkgs, ... }: {
    home = {
      homeDirectory = lib.mkForce "/Users/syp";
    };

    imports = self.suites.home.darwin;
  };
}

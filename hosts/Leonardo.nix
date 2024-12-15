{ self, ... }:
{
  system.stateVersion = 5;


  #################
  # Darwin config #
  #################

  security.pam.enableSudoTouchIdAuth = true;

  # Use F1, F2, etc. keys as standard function keys
  system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;

  system.defaults.trackpad = {
    Dragging = true;
    TrackpadThreeFingerDrag = true;
  };

  system.defaults.universalaccess.mouseDriverCursorSize = 1.5;


  #################
  # System config #
  #################

  imports = self.suites.darwin.workstation ++ (with self.users; [ syp ]);


  ###############
  # User config #
  ###############

  home-manager.users.syp = {
    imports = self.suites.home.darwin;
  };
}

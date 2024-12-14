{ self, ... }:
{
  system.stateVersion = 5;


  #################
  # Darwin config #
  #################

  security.pam.enableSudoTouchIdAuth = true;


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

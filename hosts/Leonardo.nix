{ self, pkgs, ... }:
{
  system.stateVersion = 5;

  #################
  # Darwin config #
  #################

  security.pam.services.sudo_local.touchIdAuth = true;

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

  homebrew = {
    casks = [
      #"playcover-community"
      "baidunetdisk"
      "tencent-meeting"
      "chatgpt"
    ];
  };

  services.tailscale.enable = true;

  nix.linux-builder = {
    enable = true;
    package = pkgs.darwin.linux-builder-vz;

    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    config.virtualisation = {
      cores = 12;

      darwin-builder = {
        diskSize = 64 * 1024;
        memorySize = 32 * 1024;
      };

      vz.rosetta.enable = true;
    };
  };

  ###############
  # User config #
  ###############

  home-manager.users.syp = {
    imports = self.suites.home.darwin;

    home.packages = [ pkgs.llm-agents.codex ];
  };
}

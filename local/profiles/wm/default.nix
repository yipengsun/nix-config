{ pkgs, ... }:
{
  xinit = {
    envVars = {
      XMODIFIERS = "@im=fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "xim";
    };

    initExtra = ''
      # TrackPoint settings
      tpset() { xinput set-prop "TPPS/2 ALPS TrackPoint" "$@"; }
      tpset "Evdev Wheel Emulation" 1
      tpset "Evdev Wheel Emulation Buttom" 2

      fcitx -r
    '';
  };

  xinit.windowManager.awesome = {
    enable = true;

    luaModules = with pkgs; [
      luaPackages.vicious
    ];
  };
}

{ pkgs, ... }:
{
  xinit = {
    enable = true;

    initExtra = ''
      # TrackPoint settings
      tpset() { xinput set-prop "TPPS/2 ALPS TrackPoint" "$@"; }
      tpset "Evdev Wheel Emulation" 1
      tpset "Evdev Wheel Emulation Buttom" 2
      tpset "Evdev Wheel Emulation Axes" 6 7 4 5
    '';
  };

  xinit.windowManager.awesome = {
    enable = true;

    luaModules = with pkgs; [
      luaPackages.vicious
    ];
  };

  i18n.inputMethod.enabled = "fcitx";
}

{ pkgs, ... }:
{
  # sadly you need to put this line in your host setting manually:
  #   services.xserver.displayManager.startx.enable = true;
  xinit = {
    enable = true;
  };

  xinit.windowManager.awesome = {
    enable = true;

    luaModules = with pkgs; [
      luaPackages.vicious
    ];
  };

  i18n.inputMethod.enabled = "fcitx";
}

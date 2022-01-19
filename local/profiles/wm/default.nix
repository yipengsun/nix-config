{ pkgs, ... }:
{
  xinit.windowManager.awesome = {
    enable = true;

    luaModules = with pkgs; [
      luaPackages.vicious
    ];
  };
}

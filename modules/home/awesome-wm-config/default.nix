{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.awesome-wm-config;
  customLuaPackages = pkgs.lua53Packages;

  requiredPackages = with pkgs; [
    awesomesearch
    awesome-volume-control
    scrot
  ];
in
{
  imports = [
    ./lua.nix
    ./options.nix
  ];

  config = mkIf cfg.enable {
    home.packages = requiredPackages ++ cfg.extraPackages;

    xsession.enable = true;
    xsession.windowManager.awesome = {
      enable = true;
      package = pkgs.awesome.override { lua = customLuaPackages.lua; };
      luaModules = [
        customLuaPackages.vicious
        customLuaPackages.lain
      ];
    };
  };
}

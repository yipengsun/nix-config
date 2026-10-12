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
      package = pkgs.awesome.override (
        args:
        if args ? lua5_2_compat then
          { lua5_2_compat = customLuaPackages.lua; }
        else
          # FIXME: Drop the old argument once nixpkgs-pointer includes NixOS/nixpkgs#569839.
          { lua = customLuaPackages.lua; }
      );
      luaModules = [
        customLuaPackages.vicious
        customLuaPackages.lain
      ];
    };
  };
}

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
      # FIXME: Once nixpkgs-pointer includes NixOS/nixpkgs#569839, replace with:
      # package = pkgs.awesome.override { lua5_2_compat = customLuaPackages.lua; };
      package = pkgs.awesome.override (
        args:
        if args ? lua5_2_compat then
          { lua5_2_compat = customLuaPackages.lua; }
        else
          { lua = customLuaPackages.lua; }
      );
      luaModules = [
        customLuaPackages.vicious
        customLuaPackages.lain
      ];
    };
  };
}

{ pkgs, config, ... }:

let
  customLuaPackages = pkgs.lua53Packages;

  weatherApiKeyLoc = "${config.xdg.configHome}/awesome/weather_api_key";

  mkOut = config.lib.file.mkOutOfStoreSymlink;
  stupidPath = path: "${config.home.homeDirectory}/src/nix-config/local/profiles/wm/" + path;
  # FIXME: this project now has to be placed at ~/src/nix-config
in

{
  # decrypt openweather API key
  homeage.file."weather_api_key" = {
    source = ../../../secrets/weather_api_key.age;
    symlinks = [ weatherApiKeyLoc ];
  };
  xinit.requiredFiles = [ weatherApiKeyLoc ];

  # sadly you need to put this line in your host setting manually:
  #   services.xserver.displayManager.startx.enable = true;
  xinit.enable = true;

  xinit.windowManager.awesome = {
    enable = true;

    package = pkgs.awesome.override { lua = customLuaPackages.lua; };
    luaPackages = customLuaPackages;

    luaModules = [
      customLuaPackages.vicious
      customLuaPackages.lain
    ];
  };

  # copy fcitx5 config out of store
  # FIXME: this is an ugly workaround to make hm links out-of-store
  #        see https://github.com/nix-community/home-manager/issues/2085#issuecomment-861740971
  #        somehow the 'builtins.toString' method doesn't work?!
  xdg.configFile."fcitx5/config".source = mkOut (stupidPath "fcitx5/config");
  xdg.configFile."fcitx5/profile".source = mkOut (stupidPath "fcitx5/profile");
  xdg.configFile."fcitx5/conf/classicui.conf".source = mkOut (stupidPath "fcitx5/conf/classicui.conf");
  xdg.configFile."fcitx5/conf/pinyin.conf".source = mkOut (stupidPath "fcitx5/conf/pinyin.conf");
  xdg.configFile."fcitx5/conf/cloudpinyin.conf".source = mkOut (stupidPath "fcitx5/conf/cloudpinyin.conf");
  xdg.configFile."fcitx5/conf/punctuation.conf".source = mkOut (stupidPath "fcitx5/conf/punctuation.conf");

  # lets also define programs that run with X here
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-chinese-addons
    fcitx5-material-color
    fcitx5-pinyin-zhwiki # huge Chinese dict for pinyin input
  ];

  # enable dropbox
  services.dropbox-autoreconnect.enable = true;
}

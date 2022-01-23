{ pkgs, config, ... }:

let
  customLuaPackages = pkgs.lua53Packages;
in

{
  home.packages = with pkgs; [
    i3lock
  ];

  # decrypt openweather API key
  homeage.file."weather_api_key" = {
    source = ../../../secrets/weather_api_key.age;
    symlinks = [ "${config.xdg.configHome}/awesome/weather_api_key" ];
  };
  xinit.requiredFiles = [ "~/.config/awesome/weather_api_key" ];

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

  # copy fcitx5 config
  xdg.configFile."fcitx5/config".source = ./fcitx5/config;
  xdg.configFile."fcitx5/profile".source = ./fcitx5/profile;
  xdg.configFile."fcitx5/conf/classicui.conf".source = ./fcitx5/conf/classicui.conf;
  xdg.configFile."fcitx5/conf/pinyin.conf".source = ./fcitx5/conf/pinyin.conf;
  xdg.configFile."fcitx5/conf/cloudpinyin.conf".source = ./fcitx5/conf/cloudpinyin.conf;
  xdg.configFile."fcitx5/conf/punctuation.conf".source = ./fcitx5/conf/punctuation.conf;

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

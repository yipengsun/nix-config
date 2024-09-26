{ pkgs
, config
, lib
, ...
}:
with lib; let
  customLuaPackages = pkgs.lua52Packages;

  weatherApiKeyLoc = "${config.xdg.configHome}/awesome/weather_api_key";

  fcitxDstPath = path: "${config.xdg.configHome}/fcitx5/" + path;
  fcitxConfigFiles = [
    {
      src = ./fcitx5/config;
      dst = fcitxDstPath "config";
    }
    {
      src = ./fcitx5/profile;
      dst = fcitxDstPath "profile";
    }
    {
      src = ./fcitx5/conf/classicui.conf;
      dst = fcitxDstPath "conf/classicui.conf";
    }
    {
      src = ./fcitx5/conf/cloudpinyin.conf;
      dst = fcitxDstPath "conf/cloudpinyin.conf";
    }
    {
      src = ./fcitx5/conf/pinyin.conf;
      dst = fcitxDstPath "conf/pinyin.conf";
    }
    {
      src = ./fcitx5/conf/punctuation.conf;
      dst = fcitxDstPath "conf/punctuation.conf";
    }
  ];
in
rec {
  # decrypt openweather API key
  age.secrets.weather_api_key_syp = {
    file = ../../../secrets/weather_api_key.age;
    path = weatherApiKeyLoc;
  };

  #xinit.requiredFiles = [ weatherApiKeyLoc ];

  xsession.enable = true;
  xsession.windowManager.awesome = {
    enable = true;

    package = pkgs.awesome.override { lua = customLuaPackages.lua; };

    luaModules = [
      customLuaPackages.vicious
      customLuaPackages.lain
    ];
  };

  awesome-wm-config.enable = true;

  # copy fcitx5 config on generation and forget about it
  #home.activation.copyFcitxConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
  #  ${concatMapStrings (x: "chmod 644 ${x.dst}\n") fcitxConfigFiles}
  #  ${concatMapStrings (x: "cp ${builtins.toString x.src} ${x.dst}\n") fcitxConfigFiles}
  #  ${concatMapStrings (x: "chmod 644 ${x.dst}\n") fcitxConfigFiles}
  #'';

  # lets also define programs that run with X here
  #i18n.inputMethod.enabled = "fcitx5";
  #i18n.inputMethod.fcitx5.addons = with pkgs; [
  #  fcitx5-chinese-addons
  #  fcitx5-material-color
  #  fcitx5-pinyin-zhwiki # huge Chinese dict for pinyin input
  #];

  # enable dropbox
  #services.dropbox-autoreconnect.enable = true;
}

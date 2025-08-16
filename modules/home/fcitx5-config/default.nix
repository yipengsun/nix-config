{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fcitx5-config;

  fcitxDraculaTheme = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "fcitx5-dracula-theme";
    version = "20240929";

    src = pkgs.fetchFromGitHub {
      owner = "drbbr";
      repo = pname;
      rev = "a267e6f6aea361f3ebf2f8cd3b1e56c134321a2d";
      sha256 = "sha256-aah25igObbTXjQZEFIsfmj94S4PeZ0ay3P/OBtE6WnE=";
    };

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      for f in ./*.png; do
        install -Dm644 $f -t $out/share/fcitx5/themes/${pname}/
      done

      install -Dm644 theme.conf -t $out/share/fcitx5/themes/${pname}/
    '';
  };

  fcitxConfigDir = path: "${config.xdg.configHome}/fcitx5/${path}";
  fcitxConfigFiles = [
    {
      src = ./config;
      dst = fcitxConfigDir "config";
    }
    {
      src = ./profile;
      dst = fcitxConfigDir "profile";
    }
    {
      src = ./conf/classicui.conf;
      dst = fcitxConfigDir "conf/classicui.conf";
    }
    {
      src = ./conf/cloudpinyin.conf;
      dst = fcitxConfigDir "conf/cloudpinyin.conf";
    }
    {
      src = ./conf/pinyin.conf;
      dst = fcitxConfigDir "conf/pinyin.conf";
    }
    {
      src = ./conf/punctuation.conf;
      dst = fcitxConfigDir "conf/punctuation.conf";
    }
  ];
in
{
  options.fcitx5-config = {
    enable = mkEnableOption "fcitx5 config.";

    addons = mkOption {
      default = with pkgs; [
        fcitx5-chinese-addons
        nur.repos.ruixi-rebirth.fcitx5-pinyin-moegirl
        nur.repos.ruixi-rebirth.fcitx5-pinyin-zhwiki
        fcitxDraculaTheme
      ];
      type = types.listOf types.package;
    };
  };

  config = mkIf cfg.enable {
    i18n.inputMethod.enable = true;
    i18n.inputMethod.type = "fcitx5";
    i18n.inputMethod.fcitx5.addons = cfg.addons;

    home.activation.copyFcitxConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
      ${concatMapStrings (x: "cp ${builtins.toString x.src} ${x.dst}\n") fcitxConfigFiles}
      ${concatMapStrings (x: "chmod 644 ${x.dst}\n") fcitxConfigFiles}
    '';
  };
}

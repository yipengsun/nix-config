{ config
, pkgs
, lib
, ...
}:
with lib; let
  cfg = config.i18n.inputMethod.fcitx;
  fcitxPackage = pkgs.fcitx.override { plugins = cfg.engines; };
  fcitxEngine =
    types.package
    // {
      name = "fcitx-engine";
      check = x:
        types.package.check x && attrByPath [ "meta" "isFcitxEngine" ] false x;
    };
in
{
  disabledModules = [
    "i18n/input-method/fcitx.nix"
  ];

  options = {
    i18n.inputMethod.fcitx = {
      engines = mkOption {
        type = with types; listOf fcitxEngine;
        default = [ ];
        example = literalExpression "with pkgs.fcitx-engines; [ mozc hangul ]";
        description =
          let
            enginesDrv = filterAttrs (const isDerivation) pkgs.fcitx-engines;
            engines =
              concatStringsSep ", "
                (map (name: "<literal>${name}</literal>") (attrNames enginesDrv));
          in
          "Enabled Fcitx engines. Available engines are: ${engines}.";
      };
    };
  };

  config = mkIf (config.i18n.inputMethod.enabled == "fcitx") {
    i18n.inputMethod.package = fcitxPackage;

    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };

    xinit.initExtra = "${fcitxPackage}/bin/fcitx -r";
  };
}

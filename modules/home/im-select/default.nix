{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.im-select;

  isDarwin = pkgs.stdenv.isDarwin;
  hasFcitx5 = config.i18n.inputMethod.enable && config.i18n.inputMethod.type == "fcitx5";
  isSupported = isDarwin || hasFcitx5;

  selectorCommand =
    if isDarwin then getExe pkgs.macism else getExe' config.i18n.inputMethod.package "fcitx5-remote";
in
{
  options.im-select = {
    enable = mkOption {
      type = types.bool;
      default = isSupported;
      description = "Enable im-select support.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = isSupported;
        message = "im-select requires macOS or Fcitx5 on Linux.";
      }
    ];

    home.packages = optionals isDarwin [ pkgs.macism ];

    programs.neovim.plugins = optionals isSupported [
      {
        plugin = pkgs.vimPlugins.im-select-nvim;
        type = "lua";
        config = ''
          require('im_select').setup{
            default_command = "${selectorCommand}",
            set_default_events = { "InsertLeave" },
            set_previous_events = { "InsertEnter" }
          }
        '';
      }
    ];
  };
}

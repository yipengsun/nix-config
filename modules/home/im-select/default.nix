{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.im-select;

  hasFcitx = config.i18n.inputMethod.enable && config.i18n.inputMethod.type == "fcitx5";

  im-select-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "im-select-nvim";
    version = "20250810";
    src = pkgs.fetchFromGitHub {
      owner = "keaising";
      repo = "im-select.nvim";
      rev = "113a6905a1c95d2990269f96abcbad9718209557";
      sha256 = "sha256-rtbqJjih9yy2svMIro7FbdH9DqGTumAmfcRICfqT8tQ=";
    };
  };
in
{
  options.im-select = {
    enable = mkOption {
      type = types.bool;
      default = hasFcitx;
      description = "Enable im-select support.";
    };
  };

  config = mkIf (cfg.enable) {
    programs.neovim.plugins = [
      {
        plugin = im-select-nvim;
        type = "lua";
        config = ''
          require('im_select').setup{
            set_default_events = { "InsertLeave" },
            set_previous_events = { "InsertEnter" }
          }
        '';
      }
    ];
  };
}

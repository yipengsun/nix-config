{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.im-select;

  hasFcitx = config.i18n.inputMethod.enabled == "fcitx5";

  im-select-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "im-select-nvim";
    version = "20240928";
    src = pkgs.fetchFromGitHub {
      owner = "keaising";
      repo = "im-select.nvim";
      rev = "6425bea7bbacbdde71538b6d9580c1f7b0a5a010";
      sha256 = "sha256-sE3ybP3Y+NcdUQWjaqpWSDRacUVbRkeV/fGYdPIjIqg=";
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
        config = ''
          lua << EOF
            require('im_select').setup{
              set_default_events = { "InsertLeave" },
              set_previous_events = { "InsertEnter" }
            }
          EOF
        '';
      }
    ];
  };
}

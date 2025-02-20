{ osConfig, ... }:
let
  enableImagePreview =
    if osConfig ? "wsl"
    then !osConfig.wsl.enable
    else true;
in
{
  programs.ranger = {
    enable = true;

    settings = {
      column_ratios = "1,1,3,4";
      unicode_ellipsis = true;
      scroll_offset = 8;
      shorten_title = 3;
      tilde_in_titlebar = true;
      status_bar_on_top = false;
      draw_borders = true;

      # image preview
      preview_images = enableImagePreview;
      preview_images_method = "iterm2";
    };
  };
}

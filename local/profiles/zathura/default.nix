{
  programs.zathura = {
    enable = true;
    options = {
      # dracula color theme
      notification-error-bg = "#ff5555"; # Red
      notification-error-fg = "#f8f8f2"; # Foreground
      notification-warning-bg = "#ffb86c"; # Orange
      notification-warning-fg = "#44475a"; # Selection
      notification-bg = "#282a36"; # Background
      notification-fg = "#f8f8f2"; # Foreground

      completion-bg = "#282a36"; # Background
      completion-fg = "#6272a4"; # Comment
      completion-group-bg = "#282a36"; # Background
      completion-group-fg = "#6272a4"; # Comment
      completion-highlight-bg = "#44475a"; # Selection
      completion-highlight-fg = "#f8f8f2"; # Foreground

      index-bg = "#282a36"; # Background
      index-fg = "#f8f8f2"; # Foreground
      index-active-bg = "#44475a"; # Current Line
      index-active-fg = "#f8f8f2"; # Foreground

      inputbar-bg = "#282a36"; # Background
      inputbar-fg = "#f8f8f2"; # Foreground
      statusbar-bg = "#282a36"; # Background
      statusbar-fg = "#f8f8f2"; # Foreground

      highlight-color = "#ffb86c"; # Orange
      highlight-active-color = "#ff79c6"; # Pink

      default-bg = "#282a36"; # Background
      default-fg = "#f8f8f2"; # Foreground

      render-loading = "true";
      render-loading-fg = "#282a36"; # Background
      render-loading-bg = "#f8f8f2"; # Foreground

      # recolor mode settings
      recolor-lightcolor = "#282a36"; # Background
      recolor-darkcolor = "#f8f8f2"; # Foreground

      # startup options
      adjust-open = "width";
      # recolor = "true"; # start in invert color mode (night mode)
    };
  };
}

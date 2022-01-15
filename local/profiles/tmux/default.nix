{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 250;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
          #set -g status-justify centre

          set -g @dracula-refresh-rate 6
          set -g @dracula-show-left-icon session
          set -g @dracula-show-flags false
          set -g @dracula-military-time true

          set -g @dracula-plugins "cpu-usage ram-usage time"
        '';
      }
    ];

    extraConfig = builtins.readFile ./tmux.conf;
  };
}

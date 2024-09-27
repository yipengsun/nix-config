{
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 250;
    terminal = "tmux-256color";
    extraConfig = builtins.readFile ./tmux.conf;
  };
}

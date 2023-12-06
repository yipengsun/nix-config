{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 250;
    extraConfig = builtins.readFile ./tmux.conf;
  };
}

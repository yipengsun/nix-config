{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.wget ];

  programs.nix-ld.enable = true;
}

{ pkgs, ... }:
{
  home.packages = [ pkgs.ranger pkgs.ueberzug ];

  xdg.configFile."ranger/rc.conf".source = ./rc.conf;
}

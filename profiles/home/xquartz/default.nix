{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xquartz
  ];

  home.sessionVariables = {
    DISPLAY = ":0";
  };
}

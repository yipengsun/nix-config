{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    dejavu_fonts
    wqy_microhei
    nerd-fonts.fira-code
    nerd-fonts.dejavu-sans-mono
  ];
}

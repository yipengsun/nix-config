{ pkgs, ... }:
let
  pythonCommon = pkgs.python3.withPackages (ps: with ps; [
    numpy
  ]);
in
{
  home.packages = [ pythonCommon ];
}

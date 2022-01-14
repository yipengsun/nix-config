{ pkgs, ... }:
let
  pythonCommon = pkgs.python3.withPackages (ps: with ps; [
    numpy
    jedi
    flake8
    pylint
  ]);
in
{
  home.packages = [ pythonCommon ];
}

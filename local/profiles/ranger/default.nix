{ pkgs, ... }:

let
  rangerWrapped = pkgs.symlinkJoin {
    name = "ranger-bundle";
    paths = [ pkgs.ranger pkgs.ueberzug ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for prog in ranger rifle ueberzug; do
        wrapProgram $out/bin/$prog --prefix PYTHONPATH : $out/lib
      done
    '';
  };
in

{
  home.packages = [ rangerWrapped ];

  xdg.configFile."ranger/rc.conf".source = ./rc.conf;
}

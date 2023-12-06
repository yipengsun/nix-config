{ stdenv
, python3
, pamixer
, symlinkJoin
, makeWrapper
,
}:
let
  pkgName = "awesome-volume-control";

  scriptUnwrapped = stdenv.mkDerivation {
    name = pkgName + "-unwrapped";
    src = ./.;

    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp ${./volume-control.py} $out/bin/volume-control.py
      chmod +x $out/bin/volume-control.py
    '';
  };

  scriptBuildInputs = [ pamixer ];
in
symlinkJoin {
  name = pkgName;
  paths = [ scriptUnwrapped ] ++ scriptBuildInputs;
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/volume-control.py --prefix PATH : $out/bin";
}

{
  lib,
  python3Packages,
  pamixer,
}:
python3Packages.buildPythonApplication {
  pname = "awesome-volume-control";
  version = "1.0.0";

  src = ./.;

  pyproject = false;
  dontBuild = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ pamixer ])
  ];

  installPhase = ''
    install -Dm755 ./volume-control.py $out/bin/volume-control.py
  '';

  meta.platforms = lib.platforms.linux;
}

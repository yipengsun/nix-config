{
  python3Packages,
  pamixer,
}:
python3Packages.buildPythonApplication {
  pname = "awesome-volume-control";
  version = "1.0.0";

  propagatedBuildInputs = [ pamixer ];

  src = ./.;

  format = "other";
  dontBuild = true;

  installPhase = ''
    install -Dm755 ./volume-control.py $out/bin/volume-control.py
  '';
}

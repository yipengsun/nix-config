{ python3Packages }:
python3Packages.buildPythonApplication {
  pname = "tridactyl-native-python";
  version = "0.1.11";

  src = ./.;

  format = "other";
  dontBuild = true;

  installPhase = ''
    install -Dm755 ./native_main.py $out/bin/native_main.py

    mkdir -p "$out/lib/mozilla/native-messaging-hosts"
    sed -i -e "s|REPLACE_ME_WITH_SED|$out/bin/native_main.py|" "tridactyl.json"
    cp tridactyl.json "$out/lib/mozilla/native-messaging-hosts/"
  '';
}

{ writeScriptBin
, symlinkJoin
, makeWrapper
, atool
, zip
}:
let
  scriptName = "receipt-archive";
  scriptUnwrapped = writeScriptBin scriptName (builtins.readFile ./receipt-archive);
in
symlinkJoin {
  name = scriptName;
  paths = [ scriptUnwrapped zip atool ];
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${scriptName} --prefix PATH : $out/bin";
}

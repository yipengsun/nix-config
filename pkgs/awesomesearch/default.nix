{ writeScriptBin
, symlinkJoin
, makeWrapper
,
}:
let
  scriptName = "awesomesearch";
  scriptUnwrapped = writeScriptBin scriptName (builtins.readFile ./awesomesearch);
in
symlinkJoin {
  name = scriptName;
  paths = [ scriptUnwrapped ];
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${scriptName} --prefix PATH : $out/bin";
}

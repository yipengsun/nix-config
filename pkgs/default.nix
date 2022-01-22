final: prev: {
  # keep sources this first
  # sources = prev.callPackage (import ./_sources/generated.nix) { };
  # then, call packages with `final.callPackage`

  adate = prev.writeScriptBin "adate" ''
    for i in Asia/Shanghai US/{Eastern,Pacific} Europe/{London,Paris,Berlin}; do
      printf %-22s "$i:";TZ=$i date +"%m-%d %a %H:%M"
    done
  '';

  lua5_3 = prev.lua5_3.override {
    packageOverrides = luafinal: luaprev: {
      lain = luaprev.toLuaModule (prev.stdenv.mkDerivation {
        pname = "lain";
        version = "unstable-20210925";

        src = prev.fetchFromGitHub {
          owner = "lcpz";
          repo = "lain";
          rev = "4933d6";
          sha256 = "NPXsgKcOGp4yDvbv/vouCpDhrEcmXsM2I1IUkDadgjw=";
        };

        buildInputs = [ luaprev.lua ];

        installPhase = ''
          mkdir -p $out/lib/lua/${luaprev.lua.luaversion}/
          cp -r . $out/lib/lua/${luaprev.lua.luaversion}/lain/
          printf "package.path = '$out/lib/lua/${luaprev.lua.luaversion}/?/init.lua;' ..  package.path\nreturn require((...) .. '.init')\n" > $out/lib/lua/${luaprev.lua.luaversion}/lain.lua
        '';
      });
    };
  };

  lua53Packages = final.lua5_3.pkgs;
}

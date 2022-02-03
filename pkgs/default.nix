final: prev:
{
  # keep sources this first
  # sources = prev.callPackage (import ./_sources/generated.nix) { };
  # then, call packages with `final.callPackage`

  ###########
  # general #
  ###########

  adate = prev.writeScriptBin "adate" ''
    for i in Asia/Shanghai US/{Eastern,Pacific} Europe/{London,Paris,Berlin}; do
      printf %-22s "$i:";TZ=$i date +"%m-%d %a %H:%M"
    done
  '';

  git-author-rewrite = prev.writeScriptBin "git-author-rewrite" (builtins.readFile ./git-author-rewrite/git-author-rewrite);

  colortest = prev.writeScriptBin "colortest" ''
    ${prev.gawk}/bin/awk -v term_cols="''${width:-''$(tput cols || echo 80)}" 'BEGIN{
        s="/\\";
        for (colnum = 0; colnum<term_cols; colnum++) {
            r = 255-(colnum*255/term_cols);
            g = (colnum*510/term_cols);
            b = (colnum*255/term_cols);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum%2+1,1);
        }
        printf "\n";
    }'
  '';

  ##################
  # awesome wm aux #
  ##################

  awesomesearch = prev.callPackage ./awesomesearch { };
  awesome-volume-control = prev.callPackage ./awesome-volume-control { };

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

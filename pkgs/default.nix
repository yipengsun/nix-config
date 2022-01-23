final: prev:

let
  buildPythonApplication = prev.python3Package.buildPythonApplication;
in
{
  # keep sources this first
  # sources = prev.callPackage (import ./_sources/generated.nix) { };
  # then, call packages with `final.callPackage`

  awesomesearch = prev.writeScriptBin "awesomesearch" ''
    ##############################################################
    # Original Author:  Evan Ng, 2013                            #
    #                                                            #
    # Don't forget to change the locale of your search engines   #
    # to ones you to the correct locale that you are in.         #
    # i.e:   google.co.uk, ebay.se, etc                          #
    #                                                            #
    ##############################################################
    #definitions
    browser="firefox"
    google="http://www.google.com/search?q="
    reddit="reddit.com/search?q="
    ebay="www.ebay.ca/sch/items/"
    ddg="https://www.duckduckgo.com/?q="
    wiki="en.wikipedia.org/wiki/"
    youtube="https://www.youtube.com/results?search_query="

    # search Engine can be one of g, y, d, e, b, w
    # $1 pulls out only the first argument
    searchEngine=$1

    # query is the searchEngine letter AND the search terms
    # i.e.   "g sennheiser headphones"
    query=''${@}

    # searchTerms is the search terms isolated:
    # i.e.  "sennheiser headphones"
    searchTerms=''${query:''${#searchEngine}}

    # stformatted is the search terms with "+" placed in between
    # space; since we all know how browsers hate spaces.
    # i.e. "sennheiser+headphones"
    stformatted=$(echo $searchTerms | sed 's/ /+/g')

    if [ ''${#searchEngine} == 1 ]; then
        if [[ "$searchEngine" != "g" && "$searchEngine" != "y" &&
            "$searchEngine" != "d" && "$searchEngine" != "w" &&
            "$searchEngine" != "e" && "$searchEngine" != "r" ]];
        then
            echo "not a valid defined search engine"
        else
            case $searchEngine in
            g)
                $browser "''${google}$stformatted"
                ;;
            "y")
                $browser "''${youtube}$stformatted"
                ;;
            "d")
                $browser "''${ddg}$stformatted"
                ;;
            "w")
                wikistring=$(echo $searchTerms | sed 's/ /_/g')
                $browser "''${wiki}$wikistring"
                ;;
            "e")
                $browser "''${ebay}$stformatted"
                ;;
            "r")
                $browser "''${reddit}$stformatted"
                ;;
            *)
                echo "invalid search engine type, please try again"
                ;;
            esac
        fi
    else
        echo "search engine field parameter either too long, or empty"
    fi
  '';

  adate = prev.writeScriptBin "adate" ''
    for i in Asia/Shanghai US/{Eastern,Pacific} Europe/{London,Paris,Berlin}; do
      printf %-22s "$i:";TZ=$i date +"%m-%d %a %H:%M"
    done
  '';

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

channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  inherit (channels.latest)
    cachix
    discord
    nixpkgs-fmt
    deploy-rs
    rage
    ;

  hashutils = prev.symlinkJoin {
    name = "hashutils";
    paths = map (prog: prev.writeScriptBin prog "${prev.busybox}/bin/${prog} $@") [
      "md5sum"
      "sha256sum"
      "sha512sum"
    ];
  };

  haskellPackages = prev.haskellPackages.override
    (old: {
      overrides = prev.lib.composeExtensions (old.overrides or (_: _: { })) (hfinal: hprev:
        let version = prev.lib.replaceChars [ "." ] [ "" ] prev.ghc.version;
        in
        {
          # same for haskell packages, matching ghc versions
          inherit (channels.latest.haskell.packages."ghc${version}")
            haskell-language-server;
        });
    });

  root = prev.root.overrideAttrs
    (old: rec {
      postInstall = ''
        for prog in rootbrowse rootcp rooteventselector rootls rootmkdir rootmv rootprint rootrm rootslimtree; do
          wrapProgram "$out/bin/$prog" \
            --set PYTHONPATH "$out/lib" \
            --set LD_LIBRARY_PATH "$out/lib"
        done
      '';
    });
}

{ pkgs, extraModulesPath, inputs, lib, ... }:
let
  inherit
    (pkgs)
    nix
    agenix
    cachix
    nixpkgs-fmt
    editorconfig-checker
    nixos-generators
    ;

  pkgWithCategory = category: package: { inherit package category; };
  devos = pkgWithCategory "devos";
  fmt = pkgWithCategory "linter";
in
{
  imports = [ "${extraModulesPath}/git/hooks.nix" ./hooks ];

  packages = [ ];

  commands = with pkgs; [
    (devos nix)
    (devos agenix)

    (fmt nixpkgs-fmt)
    (fmt editorconfig-checker)
  ]

  ++ lib.optional
    (system != "i686-linux")
    (devos cachix)
  ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux && !pkgs.stdenv.buildPlatform.isDarwin) [
    (devos nixos-generators)
    (devos inputs.deploy.packages.${pkgs.system}.deploy-rs)
  ];
}

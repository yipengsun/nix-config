{ pkgs, extraModulesPath, inputs, ... }:
let
  hooks = import ./hooks;

  pkgWithCategory = category: package: { inherit package category; };
  linter = pkgWithCategory "linter";
  docs = pkgWithCategory "docs";
  devos = pkgWithCategory "devos";
in
{
  _file = toString ./.;

  imports = [ "${extraModulesPath}/git/hooks.nix" ];
  git = { inherit hooks; };

  commands = with pkgs; [
    (devos nixUnstable)
    (devos agenix)
    #{
    #  category = "devos";
    #  name = pkgs.nvfetcher-bin.pname;
    #  help = pkgs.nvfetcher-bin.meta.description;
    #  command = "cd $PRJ_ROOT/pkgs; ${pkgs.nvfetcher-bin}/bin/nvfetcher -c ./sources.toml $@";
    #}
    (linter nixpkgs-fmt)
    (linter editorconfig-checker)
    (linter pkgs.luaformatter)
    (devos inputs.deploy.packages.${pkgs.system}.deploy-rs)
  ]

  ++ lib.optional
    (system != "i686-linux")
    (devos cachix)
  ;
}

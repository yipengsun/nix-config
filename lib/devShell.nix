{ lib, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      pre-commit = {
        check.enable = true;

        settings.hooks = {
          actionlint.enable = true;
          deadnix.enable = true;
          editorconfig-checker.enable = true;
          lua-syntax = {
            enable = true;
            package = pkgs.lua5_3;
            entry = "${pkgs.lua5_3}/bin/luac -p";
            files = "\\.lua$";
          };
          nixfmt.enable = true;
          python-syntax = {
            enable = true;
            package = pkgs.ruff;
            entry = "${pkgs.ruff}/bin/ruff check --no-cache --select E9";
            types = [ "python" ];
          };
          ruff = {
            enable = true;
            entry = "${pkgs.ruff}/bin/ruff check --no-cache";
            excludes = [ "^overlays/default/tridactyl-native-python/" ];
          };
          shellcheck.enable = true;
        };
      };

      formatter = pkgs.nixfmt-tree;

      devShells.default = pkgs.mkShellNoCC {
        name = "nix-config";

        buildInputs =
          with pkgs;
          [
            nix
            agenix
            nixos-anywhere
            openssh
          ]
          ++ config.pre-commit.settings.enabledPackages
          ++ lib.optionals pkgs.stdenv.isDarwin [
            git
            darwin-rebuild
            darwin-option
            darwin-version
          ];

        shellHook = ''
          ${config.pre-commit.shellHook}
          export PATH=$(pwd)/tools:$PATH
        '';
      };
    };
}

{ lib, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      pre-commit = {
        check.enable = true;

        settings.hooks = {
          actionlint.enable = true;
          editorconfig-checker.enable = true;
          nixfmt.enable = true;
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

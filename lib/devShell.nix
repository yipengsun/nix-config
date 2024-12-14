{ lib, ... }: {
  perSystem =
    { pkgs, config, ... }: {
      pre-commit = {
        check.enable = true;

        settings.src = ./.;
        settings.hooks = {
          editorconfig-checker.enable = true;
          nixpkgs-fmt.enable = true;
        };
      };

      devShells.default = pkgs.mkShell {
        name = "nix-config";

        buildInputs = with pkgs; [
          nix
          agenix
          nixos-anywhere
        ] ++ config.pre-commit.settings.enabledPackages
        ++ lib.optionals pkgs.stdenv.isDarwin [
          git
          darwin-rebuild
          darwin-option
          darwin-version
        ];

        shellHook = ''
          ${config.pre-commit.installationScript}
          export PATH=$(pwd)/tools:$(pwd)/build/Debug:$PATH
        '';
      };
    };
}

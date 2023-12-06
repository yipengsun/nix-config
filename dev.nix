{ ... }: {
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
          #agenix  #FIXME: need to import overlay from agenix input
        ] ++ config.pre-commit.settings.enabledPackages;

        shellHook = ''
          ${config.pre-commit.installationScript}
          export PATH=$(pwd)/tools:$(pwd)/build/Debug:$PATH
        '';
      };
    };
}

let
  flakeConfig = (import ../../../flake.nix).nixConfig;
in
{
  nix.settings = {
    substituters = flakeConfig.extra-substituters;
    trusted-public-keys = flakeConfig.extra-trusted-public-keys;
  };
}

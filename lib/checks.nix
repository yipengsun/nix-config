{
  self,
  lib,
  ...
}:
{
  perSystem =
    { system, pkgs, ... }:
    let
      mkHostEvalCheck =
        name: systemDrv:
        pkgs.runCommand "eval-${name}"
          {
            evaluatedDrv = builtins.unsafeDiscardStringContext systemDrv.drvPath;
          }
          ''
            printf '%s\n' "$evaluatedDrv" > "$out"
          '';

      forCurrentSystem = lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system);

      nixosChecks = lib.mapAttrs' (
        name: host:
        lib.nameValuePair "host-${name}" (mkHostEvalCheck name host.config.system.build.toplevel)
      ) (forCurrentSystem self.nixosConfigurations);

      darwinChecks = lib.mapAttrs' (
        name: host: lib.nameValuePair "host-${name}" (mkHostEvalCheck name host.system)
      ) (forCurrentSystem self.darwinConfigurations);
    in
    {
      checks = nixosChecks // darwinChecks;
    };
}

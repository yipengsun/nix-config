{
  pkgs,
  lib,
  config,
  ...
}:
let
  zfsKernelModuleAttribute = config.boot.zfs.package.kernelModuleAttribute;

  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    let
      evaluation = builtins.tryEval (
        if
          !(builtins.hasAttr "kernel" kernelPackages)
          || !(builtins.hasAttr zfsKernelModuleAttribute kernelPackages)
        then
          false
        else
          let
            kernel = kernelPackages.kernel;
          in
          if !(builtins.hasAttr "version" kernel) then
            false
          else
            let
              zfsPackage = kernelPackages.${zfsKernelModuleAttribute};
              isBroken = zfsPackage.meta.broken or false;
            in
            !isBroken && kernel.version != ""
      );
    in
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null && evaluation.success && evaluation.value
  ) pkgs.linuxKernel.packages;

  sortedKernelPackages = lib.sort (a: b: lib.versionOlder a.kernel.version b.kernel.version) (
    builtins.attrValues zfsCompatibleKernelPackages
  );

  latestKernelPackage =
    if sortedKernelPackages == [ ] then
      throw "No ZFS-compatible kernel found for module ${zfsKernelModuleAttribute}"
    else
      lib.last sortedKernelPackages;
in
{
  boot.kernelPackages = latestKernelPackage; # latest zfs-compatible kernel

  services.zfs.trim.enable = true; # trim SSD periodically
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 1;
    hourly = 1;
    daily = 1;
    weekly = 2;
    monthly = 2;
  };
}

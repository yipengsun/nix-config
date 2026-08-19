{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nix-config.darwin.xcode;
  xcode = cfg.package;

  debugServerPath = "${xcode}/Contents/SharedFrameworks/LLDB.framework/Versions/A/Resources/debugserver";
in
{
  options.nix-config.darwin.xcode = {
    enable = lib.mkEnableOption "full Xcode for C++ LLDB debugging";
    package = lib.mkPackageOption pkgs.darwin "xcode_26" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      xcode
    ];

    environment.variables = {
      LLDB_DEBUGSERVER_PATH = debugServerPath;
    };
  };
}

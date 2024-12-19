{ pkgs, ... }:
let
  xcode = pkgs.darwin.xcode_16_1;
  # ^requires manual download, needed for c++ lldb debugging
  #   https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_16.1/Xcode_16.1.xip

  debugServerPath = "${xcode}/Contents/SharedFrameworks/LLDB.framework/Versions/A/Resources/debugserver";
in
{
  environment.systemPackages = [
    xcode
  ];

  environment.variables = {
    LLDB_DEBUGSERVER_PATH = debugServerPath;
  };
}

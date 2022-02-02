{ pkgs, ... }:
{
  # GlobalConnect VPN for UMD
  services.globalprotect = {
    enable = true;
    # if you need a Host Integrity Protection report
    # csdWrapper = "${pkgs.openconnect}/libexec/openconnect/hipreport.sh";
  };
  environment.systemPackages = [ pkgs.globalprotect-openconnect ];
}

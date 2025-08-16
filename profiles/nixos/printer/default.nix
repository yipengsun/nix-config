{ pkgs, ... }:
{
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ]; # For UMD printers

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
}

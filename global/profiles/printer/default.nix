{ pkgs, ... }:
{
  # printer at UMD PSC
  services.printing.enable = true; # trim SSD periodically
  services.printing.drivers = [
    pkgs.hplip
  ];
}

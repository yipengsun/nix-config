{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    services.blueman-applet-xinit = {
      enable = mkEnableOption "" // {
        description = ''
          Whether to enable the Blueman applet.
          </para><para>
          Note, for the applet to work, the 'blueman' service should
          be enabled system-wide. You can enable it in the system
          configuration using
          <programlisting language="nix">
            services.blueman.enable = true;
          </programlisting>
        '';
      };
    };
  };

  config = mkIf config.services.blueman-applet-xinit.enable {
    xinit.initExtra = "${pkgs.blueman}/bin/blueman-applet &";
  };
}

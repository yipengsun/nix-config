{ pkgs, ... }:
let
  edidShelfUsbC = ''
    00ffffffffffff004a8b00160100506332210104b52314782b8c75a9544598221e5054210800010181c081809500a9c0b300d1c0d100dd6800a0a0402d603020350062c71000001a000000fd0030a5f6f648010a202020202020000000fc00547970655f430a202020202020affb00a0a0402d603020450062c71000001a029b020323f4489005040302011f132309070783010000e200ffe305c000e6060501626200168300a0a0402d603020450062c71000001abcd100a0a0402d603020450062c71000001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000be7012790000030114190c0184ff098b002f801f003f062700020004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e090
  '';

  edidLenoveT14 = ''
    00ffffffffffff0030e4fa0500000000001c0104a51f117802aa95955e598e271b5054000000010101010101010101010101010101012e3680a070381f403020350035ae1000001ab62c80f4703816403020350035ae1000001a000000fe004c4720446973706c61790a2020000000fe004c503134305746412d53504432004d
  '';
in
{
  programs.autorandr = {
    enable = true;

    hooks = {
      postswitch = {
        "notify-awesome" = ''
          ${pkgs.libnotify}/bin/notify-send -t 15000 "Display profile switched" "$AUTORANDR_CURRENT_PROFILE"
        '';
      };
    };

    profiles = {
      "Thomas-mobile" = {
        fingerprint = {
          eDP = edidLenoveT14;
        };
        config = {
          HDMI-A-0.enable = false;
          DisplayPort-0.enable = false;
          DisplayPort-1.enable = false;

          eDP = {
            enable = true;
            crtc = 0;
            primary = true;
            mode = "1920x1080";
            rate = "60.00";
            position = "0x0";
          };
        };
      };

      "Thomas-home" = {
        fingerprint = {
          DisplayPort-1 = edidShelfUsbC;
          eDP = edidLenoveT14;
        };
        config = {
          HDMI-A-0.enable = false;
          DisplayPort-0.enable = false;

          DisplayPort-1 = {
            enable = true;
            crtc = 0;
            primary = false;
            mode = "2560x1600";
            rate = "155.00";
            position = "0x0";
          };
          eDP = {
            enable = true;
            crtc = 1;
            primary = true;
            mode = "1920x1080";
            rate = "60.00";
            position = "2560x1280";
          };
        };
      };
    };
  };
}

{ pkgs, lib, ... }:
{
  nix.settings = {
    system-features = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ];
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false; # I'm a lazy bastard

  environment = {
    systemPackages = with pkgs; [
      # Hardware
      pciutils

      # Utilities
      usbutils
      utillinux
      openssl
      iputils

      # Disk utilities
      dosfstools
      gptfdisk
    ];

    pathsToLink = [
      "/share"
      "/bin"
    ];
  };

  fonts = {
    fontconfig.defaultFonts = {
      monospace = [
        "FiraCode Nerd Font Mono"
        "DejaVuSansM Nerd Font Mono"
        "WenQuanYi Micro Hei Mono"
      ];
      serif = [
        "DejaVu Serif"
        "WenQuanYi Micro Hei"
      ];
      sansSerif = [
        "DejaVu Sans"
        "WenQuanYi Micro Hei"
      ];
    };
  };

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
    settings.PermitRootLogin = "no";
  };

  programs.command-not-found.enable = false;
}

{ self, config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  imports = [ ../cachix ];

  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false; # I'm a lazy bastard

  environment = {
    systemPackages = with pkgs; [
      # GNU userland
      binutils
      coreutils
      gnused

      # Utilities
      ed # ed is the standard text editor - ed man! !man ed
      usbutils
      utillinux
      bottom # top-like
      tree
      moreutils # more utils than coreutils

      # Network utilities
      curl
      iputils # ping, traceroute, etc.
      dnsutils # nslookup, etc.
      nmap # for host discovery, etc

      # Disk utilities
      dosfstools
      gptfdisk

      # Dev tools
      git
      tig
      fd # find-like
      ripgrep # grep-like
    ];

    pathsToLink = [
      "/share/zsh" # for zsh completion
    ];
  };

  fonts = {
    fonts = with pkgs; [ powerline-fonts dejavu_fonts wqy_microhei ];

    fontconfig.defaultFonts = {
      monospace = [ "DejaVu Sans Mono for Powerline" ];
      sansSerif = [ "DejaVu Sans" ];
    };
  };

  nix = {
    autoOptimiseStore = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };

    optimise.automatic = true;

    useSandbox = true;

    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
  };

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };
}

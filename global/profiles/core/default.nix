{ self, config, lib, pkgs, ... }:

let
  inherit (lib) fileContents;
in

{
  imports = [ ../cachix ];

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
      openssl
      atool
      zip
      unzip
      unrar

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
      "/share"
      "/bin"
    ];
  };

  fonts = {
    fonts = with pkgs; [
      dejavu_fonts
      wqy_microhei
      (nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
    ];

    fontconfig.defaultFonts = {
      monospace = [ "DejaVuSansMono Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
    };
  };

  nix.package = pkgs.nix; # require stable version of nix explicitly

  nix.settings = {
    system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

    auto-optimise-store = true;

    sandbox = true;

    allowed-users = [ "@wheel" ];
    trusted-users = [ "root" "@wheel" ];
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    fallback = true
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 49d";
  };

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };

  # Enable required basic nix integration for zsh
  programs.zsh.enable = true;
}

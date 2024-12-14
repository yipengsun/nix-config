{ pkgs, ... }:
let
  commonPkgs = with pkgs; [
    # GNU userland
    binutils
    coreutils
    gnused

    # Utilities
    ed # ed is the standard
    bottom # top-like
    tree
    moreutils # more utils than coreutils
    atool
    zip
    unzip
    unrar
    p7zip

    # Network utilities
    curl
    iputils # ping, traceroute, etc.
    dnsutils # nslookup, etc.
    nmap # for host discovery, etc

    # Dev tools
    git
    fd # find-like
    ripgrep # grep-like
  ];

  commonFonts = with pkgs; [
    dejavu_fonts
    wqy_microhei
    nerd-fonts.fira-code
    nerd-fonts.dejavu-sans-mono
  ];
in
{
  nix.settings = {
    auto-optimise-store = true;
    sandbox = true;
    experimental-features = [ "nix-command" "flakes" ];
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

  environment.systemPackages = commonPkgs;
  fonts.packages = commonFonts;

  programs.fish.enable = true;
  programs.nix-index.enable = true;
}

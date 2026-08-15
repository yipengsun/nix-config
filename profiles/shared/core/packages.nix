{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
    dnsutils # nslookup, etc.
    nmap # for host discovery, etc

    # Dev tools
    git
    fd # find-like
    ripgrep # grep-like
  ];

  programs.fish.enable = true;
  programs.nix-index.enable = true;
}

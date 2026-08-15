{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  nix.settings = {
    sandbox = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "root" ] ++ (if isLinux then [ "@wheel" ] else [ "@admin" ]);
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    fallback = true
  '';

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 49d";
  };

  nix.optimise.automatic = true;
}

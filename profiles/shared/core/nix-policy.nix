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
    fallback = true;
    keep-derivations = true;
    keep-outputs = true;
    trusted-users = [ "root" ] ++ (if isLinux then [ "@wheel" ] else [ "@admin" ]);
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 49d";
  };

  nix.optimise.automatic = true;
}

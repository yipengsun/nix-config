{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = if pkgs.stdenv.isLinux then pkgs.chromium else pkgs.google-chrome;

    extensions = [
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      #{ id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1password
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
    ];
  };
}

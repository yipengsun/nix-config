{ inputs, ... }:
{
  nix-homebrew = {
    enable = true;
    user = "syp";

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
    };

    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    global.autoUpdate = false;

    casks = [
      "dropbox"
    ];
  };
}

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
      whois
      usbutils
      utillinux
      curl
      bottom # top-like
      jq
      iputils
      nmap
      moreutils # more utils than coreutils
      vi # good ol' vi

      # Disk utilities
      dosfstools
      gptfdisk

      # Dev tools
      git
      direnv
      dnsutils
      fd # find-like
      ripgrep # grep-like
      nix-index
      skim
      fzf
      bat
    ];

    shellInit = ''
      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml"
        (fileContents ./starship.toml)
      }
    '';

    shellAliases =
      let ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # git
        g = "git";

        # grep
        grep = "rg";
        gi = "grep -i";

        # internet ip
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        n = "nix";
        ns = "n search --no-update-lock-file";
        nf = "n flake";
        nepl = "n repl '<nixpkgs>'";
        nsysgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        nstrayroots = ''nix-store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{memory)"'';

        # fix nixos-option
        nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";

        # sudo
        s = ifSudo "sudo -E ";
        si = ifSudo "sudo -i";
        se = ifSudo "sudoedit";

        # top
        top = "btm"; # bottom

        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = ifSudo "s systemctl start";
        dn = ifSudo "s systemctl stop";
        jtl = "journalctl";

        # Misc.
        df = "df -hT";
        du = "du -hs";
      };
  };

  fonts = {
    fonts = with pkgs; [ powerline-fonts dejavu_fonts ];

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

  programs.bash = {
    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
    interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';
  };

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };
}

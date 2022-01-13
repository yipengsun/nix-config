{ self, ... }:
{
  programs.zsh =
    let
      preztoTheme = "pure";
    in
    {
      enable = true;

      dirHashes = {
        downloads = "$HOME/downloads";
        dropbox = "$HOME/.sync/Dropbox";

        # frequently used projects
        talks = "$HOME/misc/documents/talks";
        notes = "$HOME/misc/documents/personal/notes";

        # research projects
        lhcb = "$HOME/misc/researches/lhcb-data_analysis";
        lhcb-hw = "$HOME/misc/researches/lhcb-hardware_related";
        franco = "$HOME/misc/researches/umd-franco";
      };

      shellAliases = {
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

        # sudo
        s = "sudo -E ";
        si = "sudo -i";
        se = "sudoedit";

        # top
        top = "btm"; # bottom

        # systemd
        ctl = "systemctl";
        stl = "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = "s systemctl start";
        dn = "s systemctl stop";
        jtl = "journalctl";

        # Misc.
        df = "df -hT";
        du = "du -hs";
      };

      initExtra = ''
        # Navigating command line
        bindkey '^J' backward-word
        bindkey '^K' forward-word

        # More familary history search
        autoload history-search-end
        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end history-search-end

        bindkey '^P' history-beginning-search-backward-end
        bindkey '^N' history-beginning-search-forward-end

        # Command line editing
        autoload -U edit-command-line
        zle -N edit-command-line

        bindkey '^\' edit-command-line

        # vi-style movement in auto-completion menu
        zstyle ':completion:*' menu select
        zmodload zsh/complist

        bindkey -M menuselect 'h' vi-backward-char        # left
        bindkey -M menuselect 'k' vi-up-line-or-history   # up
        bindkey -M menuselect 'l' vi-forward-char         # right
        bindkey -M menuselect 'j' vi-down-line-or-history # bottom
      '';

      prezto = {
        enable = true;
        editor.dotExpansion = true;

        prompt.pwdLength = "long";
        prompt.theme = preztoTheme;

        syntaxHighlighting.highlighters = [
          "main"
          "brackets"
          "pattern"
          "line"
          "root"
        ];
      };

      loginExtra = ''
        # Load theme for TTY
        autoload -Uz promptinit
        promptinit
        prompt ${preztoTheme}

        # Auto start awesome when login at TTY1
        if [ $(id -u) -ne 0 ] && [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
            exec startx
        fi
      '';
    };
}

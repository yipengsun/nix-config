{
  config,
  lib,
  ...
}:
with lib;
let
  preferredTerm =
    elems:
    with builtins;
    if elems == [ ] then
      "xterm"
    else if (head elems).pred then
      (head elems).value
    else
      preferredTerm (tail elems);

  defaultTerm = preferredTerm [
    {
      pred = config.programs.wezterm.enable;
      value = "wezterm";
    }
    {
      pred = config.programs.alacritty.enable;
      value = "alacritty";
    }
  ];
in
{
  options.awesome-wm-config = {
    enable = mkEnableOption "Awesome window manager config.";

    extraPackages = mkOption {
      default = [ ];
      type = types.listOf types.package;
    };

    requiredModules = mkOption {
      default = ''
        -- Standard awesome libraries
        require("awful.autofocus")
        awful     = require("awful")
        beautiful = require("beautiful")
        naughty   = require("naughty")
        wibox     = require("wibox")
        gears     = require("gears")

        -- Third-party awesome libraries
        vicious         = require("vicious")
        vicious.contrib = require("vicious.contrib")
        lain            = require("lain")
      '';
      type = types.str;
    };

    modKey = mkOption {
      default = "Mod4"; # "Mod1" for Alt
      type = types.str;
    };

    globalVariables = mkOption {
      default = {
        editor = "vi";

        terminal = defaultTerm;
        browser = "firefox";
        chrome = "chromium";
        lock = "i3lock -f -c 000000";

        poweroff = "systemctl poweroff";
        reboot = "systemctl reboot";
        suspend = "systemctl suspend";

        voldown = "volume-control.py --vol-down";
        volup = "volume-control.py --vol-up";
        volmute = "volume-control.py --mute-output";
        capmute = "volume-control.py --mute-input --index 0";

        lcdup = "xbacklight -inc 10";
        lcddown = "xbacklight -dec 10";

        mpd_next = "mpc next";
        mpd_prev = "mpc prev";
        mpd_toggle = "mpc toggle";
        mpd_stop = "mpc stop";

        prtscr = "scrot -e 'mv $f ~/ 2>/dev/null'";
      };
      type = types.attrsOf types.str;
    };

    layouts = mkOption {
      default = [
        "awful.layout.suit.tile.bottom"
        "awful.layout.suit.tile"
        "awful.layout.suit.fair"
        #"awful.layout.suit.spiral"
      ];
      type = types.listOf types.str;
    };

    tagNames = mkOption {
      default = [
        "MISC"
        "WWW"
        "COM"
        "CODE"
      ];
      type = types.listOf types.str;
    };

    tagLayouts = mkOption {
      default = [
        2
        1
        3
        2
      ];
      type = types.listOf types.int;
    };

    keybindings = mkOption {
      default = ./modules/keybindings.lua;
      type = types.path;
    };

    rulesSignals = mkOption {
      default = ./modules/rules-signals.lua;
      type = types.path;
    };

    taskbars = mkOption {
      type = types.path;
    };

    theme = mkOption {
      type = types.path;
    };

    wallpaper = mkOption {
      type = types.path;
    };
  };
}

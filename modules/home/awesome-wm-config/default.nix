{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.awesome-wm-config;

  preferredTerm = elems:
    with builtins;
    if elems == [ ] then "xterm"
    else if (head elems).pred then (head elems).value
    else preferredTerm (tail elems);

  defaultTerm = preferredTerm [
    { pred = config.programs.wezterm.enable; value = "wezterm"; }
    { pred = config.programs.alacritty.enable; value = "alacritty"; }
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
        capmute = "volume-control.py --mute-input --index 2";

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
      default = [ "MISC" "WWW" "COM" "CODE" ];
      type = types.listOf types.str;
    };

    tagLayouts = mkOption {
      default = [ 2 1 3 2 ];
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

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ awesomesearch awesome-volume-control ];

    xdg.configFile."awesome/rc.lua".text = ''
      -- Check if awesome encountered an error during startup and fall back to
      -- another config (This code will only ever execute for the fallback config)
      if awesome.startup_errors then
          naughty.notify({preset = naughty.config.presets.critical,
                          title = "Oops, there were errors during startup!",
                          text = awesome.startup_errors })
      end

      -- Handle runtime errors after startup
      do
          local in_error = false
          awesome.connect_signal("debug::error", function(err)
              -- Make sure we don't go into an endless error loop
              if in_error then return end
              in_error = true

              naughty.notify({preset = naughty.config.presets.critical,
                              title = "Oops, an error happened!",
                              text = err })
              in_error = false
          end)
      end

      ${cfg.requiredModules}

      -- Functions
      -- Wrapper function for volume notify, re-using existed pop-up window
      volnotify = {}
      volnotify.id = nil
      function volnotify:notify(msg)
          self.id = naughty.notify({ text = msg, timeout = 3, replaces_id = self.id }).id
      end

      -- Set wallpaper
      function set_wallpaper(s)
          -- Wallpaper
          if beautiful.wallpaper then
              local wallpaper = beautiful.wallpaper
              -- If wallpaper is a function, call it with the screen
              if type(wallpaper) == "function" then
                  wallpaper = wallpaper(s)
              end
              gears.wallpaper.maximized(wallpaper, s, true)
          end
      end

      -- Read from OpenWeather API key
      function read_key(file)
          local f = assert(io.open(file, "r"))
          local content = f:read("*all")
          content = string.gsub(content, "\n", "")
          f:close()
          return content
      end

      -- Config variables
      home_path  = os.getenv("HOME")
      cfg_path   = home_path.."/.config/awesome"

      -- Initialize theme
      beautiful.init(cfg_path.."/theme/theme.lua")

      -- Set default mod key
      modkey = "${cfg.modKey}"

      -- OpenWeather API key
      --weather_api_key = read_key(cfg_path.."/weather_api_key")

      -- Global variables
      ${concatStringsSep "\n" (mapAttrsToList (key: val: key + " = " + ''"'' + val + ''"'') cfg.globalVariables)}

      layouts = {
        ${concatStringsSep ",\n" cfg.layouts}
      }

      -- Tags
      tags = {
          names = {${concatMapStringsSep "," (x: ''"${x}"'') cfg.tagNames}},
          layout = {${concatMapStringsSep "," (x: "layouts[${toString x}]") cfg.tagLayouts}}
      }

      awful.screen.connect_for_each_screen(function(s)
          awful.tag(tags.names, s, tags.layout)

          -- Create a drop-down container
          s.quake = lain.util.quake({
              app = terminal,
              argname = "--title %s",
              extra = "--class QuakeDD -e tmux",
              height = 0.35,
              width = 0.65,
              horiz = "center",
              overlap = true,
              settings = function(c)
                  c.sticky = true
                  callback = awful.client.setmaster
              end
          })
      end)

      -- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
      screen.connect_signal("property::geometry", set_wallpaper)

      -- Configuration modules
      require("modules.keybindings")
      require("modules.taskbars")
      require("modules.rules-signals")
    '';

    xdg.configFile."awesome/modules/keybindings.lua".source = cfg.keybindings;
    xdg.configFile."awesome/modules/rules-signals.lua".source = cfg.rulesSignals;
    xdg.configFile."awesome/modules/taskbars.lua".source = cfg.taskbars;

    xdg.configFile."awesome/theme".source = cfg.theme;
    xdg.configFile."awesome/wallpaper".source = cfg.wallpaper;
  };
}

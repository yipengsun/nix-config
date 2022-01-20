{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.xinit.windowManager.awesome;
  awesome = cfg.package;

  getLuaPath = lib: dir: "${lib}/${dir}/lua/${cfg.luaPackages.lua.luaversion}";
  makeSearchPath = lib.concatMapStrings (path:
    " --search ${getLuaPath path "share"}"
    + " --search ${getLuaPath path "lib"}");

  awesomeCmd = "${awesome}/bin/awesome ${makeSearchPath cfg.luaModules}";
in

{
  options = {
    xinit.windowManager.awesome = {
      enable = mkEnableOption "Awesome window manager.";

      package = mkOption {
        type = types.package;
        default = pkgs.awesome;
        defaultText = literalExpression "pkgs.awesome";
        description = "Package to use for running the Awesome WM.";
      };

      luaPackages = mkOption {
        type = types.attrsOf types.package;
        default = pkgs.luaPackages;
        defaultText = literalExpression "pkgs.lua.pkgs";
        description = "Package to Lua packages.";
      };

      luaModules = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of lua packages available for being
          used in the Awesome configuration.
        '';
        example = literalExpression "[ luaPackages.vicious ]";
      };

      # awesome config
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
          scratch         = require("scratch") -- obsolete, will remove soon
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

          terminal = "alacritty";
          browser = "firefox";
          chrome = "chromium";
          lock = "i3lock -f";

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
          "awful.layout.suit.spiral"
        ];
        type = types.listOf types.str;
      };

      tagNames = mkOption {
        default = [ "MISC" "WWW" "CODE" "COM" "TERM" ];
        type = types.listOf types.str;
      };

      tagLayouts = mkOption {
        default = [ 2 1 3 2 3 ];
        type = types.listOf types.int;
      };

      keybindings = mkOption {
        default = ./awesome/modules/keybindings.lua;
        type = types.path;
      };

      rulesSignals = mkOption {
        default = ./awesome/modules/rules-signals.lua;
        type = types.path;
      };

      widgets = mkOption {
        default = ./awesome/modules/widgets.lua;
        type = types.path;
      };

      taskbars = mkOption {
        default = ./awesome/modules/taskbars.lua;
        type = types.path;
      };

      theme = mkOption {
        type = types.path;
      };

      wallpaper = mkOption {
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (hm.assertions.assertPlatform "xinit.windowManager.awesome" pkgs
        platforms.linux)
    ];

    home.packages = [ awesome pkgs.scrot ];

    xinit.windowManagerCmd = awesomeCmd;

    xdg.configFile."awesome/rc.lua".text = ''
      -- Check if awesome encountered an error during startup and fell back to
      -- another config (This code will only ever execute for the fallback config)
      if awesome.startup_errors then
          naughty.notify({preset = naughty.config.presets.critical,
                          title = "Oops, there were errors during startup!",
                          text = awesome.startup_errors })
      end

      -- Handle runtime errors after startup
      do
          local in_error = false
          awesome.connect_signal("debug::error", function (err)
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

      -- Config variables
      home_path  = os.getenv("HOME")
      cfg_path   = home_path.."/.config/awesome"

      -- Initialize theme
      beautiful.init(cfg_path.."/theme/theme.lua")

      -- Set default mod key
      modkey = "${cfg.modKey}"

      -- Global variables
      ${concatStringsSep "\n" (mapAttrsToList (key: val: key+" = "+''"''+val+''"'') cfg.globalVariables)}

      layouts = {
        ${concatStringsSep ",\n" cfg.layouts}
      }

      -- Tags
      tags = {
          names = {${concatMapStringsSep "," (x: ''"''+x+''"'') cfg.tagNames}},
          layout = {${concatMapStringsSep "," (x: "layouts["+(toString x)+"]") cfg.tagLayouts}}
      }

      awful.screen.connect_for_each_screen(function(s)
          awful.tag(tags.names, s, tags.layout)
      end)

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

      -- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
      screen.connect_signal("property::geometry", set_wallpaper)

      -- Configuration modules
      require("modules.keybindings")
      require("modules.taskbars")
      require("modules.rules-signals")
    '';

    xdg.configFile."awesome/modules/keybindings.lua".source = cfg.keybindings;
    xdg.configFile."awesome/modules/rules-signals.lua".source = cfg.rulesSignals;
    xdg.configFile."awesome/modules/widgets.lua".source = cfg.widgets;
    xdg.configFile."awesome/modules/taskbars.lua".source = cfg.taskbars;

    xdg.configFile."awesome/theme".source = cfg.theme;
    xdg.configFile."awesome/wallpaper".source = cfg.wallpaper;
  };
}

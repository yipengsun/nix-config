{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.awesome-wm-config;
in
{
  config = mkIf cfg.enable {
    xdg.configFile."awesome/rc.lua".text = ''
      local naughty = require("naughty")

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

      -- Config variables
      home_path  = os.getenv("HOME")
      cfg_path   = home_path.."/.config/awesome"

      -- Initialize theme
      beautiful.init(cfg_path.."/theme/theme.lua")

      -- Set default mod key
      modkey = ${builtins.toJSON cfg.modKey}

      -- Global variables
      ${concatStringsSep "\n" (
        mapAttrsToList (key: val: "_G[${builtins.toJSON key}] = ${builtins.toJSON val}") cfg.globalVariables
      )}

      layouts = {
        ${concatStringsSep ",\n" cfg.layouts}
      }

      -- Tags
      tags = {
          names = {${concatMapStringsSep "," builtins.toJSON cfg.tagNames}},
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

    assertions = [
      {
        assertion = length cfg.tagNames == length cfg.tagLayouts;
        message = "awesome-wm-config.tagNames and tagLayouts must have the same length";
      }
      {
        assertion = all (layout: layout >= 1 && layout <= length cfg.layouts) cfg.tagLayouts;
        message = "awesome-wm-config.tagLayouts entries must reference an existing layout";
      }
    ];

    xdg.configFile."awesome/modules/keybindings.lua".source = cfg.keybindings;
    xdg.configFile."awesome/modules/rules-signals.lua".source = cfg.rulesSignals;
    xdg.configFile."awesome/modules/taskbars.lua".source = cfg.taskbars;

    xdg.configFile."awesome/theme".source = cfg.theme;
    xdg.configFile."awesome/wallpaper".source = cfg.wallpaper;
  };
}

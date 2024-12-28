let
  modkey = "alt";
in
{
  services.aerospace = {
    enable = true;

    settings = {
      gaps = {
        outer.left = 3;
        outer.right = 3;
        outer.top = 3;
        outer.bottom = 3;

        inner.horizontal = 3;
        inner.vertical = 3;
      };
      accordion-padding = 250;

      default-root-container-layout = "tiles";

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      #on-focus-changed = "move-mouse window-lazy-center";

      automatically-unhide-macos-hidden-apps = true;

      mode.main.binding = {
        # global keys
        "${modkey}-slash" = "layout tiles horizontal vertical";
        "${modkey}-backslash" = "layout accordion horizontal vertical";

        "alt-tab" = "workspace-back-and-forth";
        "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";

        "${modkey}-a" = "macos-native-fullscreen";
        "${modkey}-f" = "close";
        "${modkey}-d" = "macos-native-minimize";

        "${modkey}-m" = "layout floating tiling";

        "${modkey}-left" = "workspace --wrap-around prev";
        "${modkey}-right" = "workspace --wrap-around next";


        # app launchers
        "${modkey}-f1" = ''exec-and-forget open -n "/Users/syp/Applications/Home Manager Apps/WezTerm.app"'';
        "${modkey}-f2" = ''exec-and-forget open -n "/Users/syp/Applications/Home Manager Apps/Firefox.app"'';


        # local client keys
        "${modkey}-h" = "focus left";
        "${modkey}-j" = "focus down";
        "${modkey}-k" = "focus up";
        "${modkey}-l" = "focus right";

        "${modkey}-shift-h" = "move left";
        "${modkey}-shift-j" = "move down";
        "${modkey}-shift-k" = "move up";
        "${modkey}-shift-l" = "move right";

        "${modkey}-minus" = "resize smart -50";
        "${modkey}-equal" = "resize smart +50";


        # workspaces
        "${modkey}-1" = "workspace 1";
        "${modkey}-2" = "workspace 2";
        "${modkey}-3" = "workspace 3";
        "${modkey}-4" = "workspace 4";
        "${modkey}-5" = "workspace 5";
        "${modkey}-6" = "workspace 6";
        "${modkey}-7" = "workspace 7";
        "${modkey}-8" = "workspace 8";
        "${modkey}-9" = "workspace 9";

        "${modkey}-i" = "workspace I";
        "${modkey}-o" = "workspace O";
        "${modkey}-p" = "workspace P";

        "${modkey}-shift-1" = "move-node-to-workspace 1";
        "${modkey}-shift-2" = "move-node-to-workspace 2";
        "${modkey}-shift-3" = "move-node-to-workspace 3";
        "${modkey}-shift-4" = "move-node-to-workspace 4";
        "${modkey}-shift-5" = "move-node-to-workspace 5";
        "${modkey}-shift-6" = "move-node-to-workspace 6";
        "${modkey}-shift-7" = "move-node-to-workspace 7";
        "${modkey}-shift-8" = "move-node-to-workspace 8";
        "${modkey}-shift-9" = "move-node-to-workspace 9";

        "${modkey}-shift-i" = "move-node-to-workspace I";
        "${modkey}-shift-o" = "move-node-to-workspace O";
        "${modkey}-shift-p" = "move-node-to-workspace P";


        # another mode
        "${modkey}-shift-semicolon" = "mode service";
      };

      mode.service.binding = {
        esc = [ "reload-config" "mode main" ];

        r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
        f = [ "layout floating tiling" "mode main" ]; # toggle between floating and tiling layout
        backspace = [ "close-all-windows-but-current" "mode main" ];

        "${modkey}-shift-h" = [ "join-with left" "mode main" ];
        "${modkey}-shift-j" = [ "join-with down" "mode main" ];
        "${modkey}-shift-k" = [ "join-with up" "mode main" ];
        "${modkey}-shift-l" = [ "join-with right" "mode main" ];
      };

      workspace-to-monitor-force-assignment = {
        "1" = "built-in";
        "2" = "built-in";
        "3" = "built-in";
        "4" = "built-in";
        "5" = "built-in";

        "6" = [ "vx3276" "secondary" "built-in" ];
        "7" = [ "vx3276" "secondary" "built-in" ];
        "8" = [ "vx3276" "secondary" "built-in" ];
        "9" = [ "vx3276" "secondary" "built-in" ];

        "I" = [ "sidecar" "secondary" "built-in" ];
        "O" = [ "sidecar" "secondary" "built-in" ];
        "P" = [ "sidecar" "secondary" "built-in" ];
      };
    };
  };
}

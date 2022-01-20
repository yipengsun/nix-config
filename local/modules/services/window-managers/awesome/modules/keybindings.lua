-- Module: keybindings.lua
-- vim:fdm=marker

--{{{ Global keys

globalkeys = awful.util.table.join(

-- Switch among tags
awful.key({                   }, "XF86Back",    awful.tag.viewprev),
awful.key({                   }, "XF86Forward", awful.tag.viewnext),

-- Move among windows
awful.key({ modkey,           }, "j", function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
end),

awful.key({ modkey,           }, "k", function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx( 1)     end),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(-1)     end),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

-- This rule apply to all size/amount adjustments
-- In general, more left keys are mapped as "bigger" function, and vice versa
-- h = more
-- l = less (reduce the size of master layout)
-- v = more
-- l = less (reduce the size of current slave client)

-- Adjust the layout between master and slave
awful.key({ modkey,           }, "h", function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey,           }, "l", function () awful.tag.incmwfact(-0.05)    end),

-- Adjust the layout between slave clients
awful.key({ modkey,           }, "v", function () awful.client.incwfact( 0.05) end),
awful.key({ modkey,           }, "n", function () awful.client.incwfact(-0.05) end),

-- Splice/merge master layout
awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1)      end),
awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1)      end),

-- Splice/merge collaterality layout
awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1)         end),

-- Switch layout
awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

-- Restore minimized client
awful.key({ modkey,           }, "s", function ()
    local c = awful.client.restore()
    if c then
        client.focus = c
        c:raise()
    end
end),

-- History
awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
awful.key({ modkey,           }, "Tab", function ()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end),

-- Control awesome
awful.key({ modkey, "Shift"   }, "q",                    awesome.quit),
awful.key({ modkey, "Shift"   }, "w",                    awesome.restart),

-- Hotkeys
awful.key({ modkey,           }, "F1",                   function () awful.util.spawn_with_shell(terminal) end),
awful.key({ modkey,           }, "F2",                   function () awful.util.spawn_with_shell(browser)  end),
awful.key({ modkey,           }, "F3",                   function () awful.util.spawn_with_shell(chrome)   end),
awful.key({ modkey,           }, "F5",                   function () awful.util.spawn_with_shell(lock)     end),

-- Powermanagement
awful.key({ modkey, "Shift"   }, "]",                    function () awful.util.spawn_with_shell(poweroff) end),
awful.key({ modkey, "Shift"   }, "[",                    function () awful.util.spawn_with_shell(reboot)   end),
awful.key({ modkey, "Shift"   }, "\\",                   function () awful.util.spawn_with_shell(suspend)  end),

-- Adjust volume
awful.key({                   }, "XF86AudioRaiseVolume", function () awful.util.spawn_with_shell(volup)   end),
awful.key({                   }, "XF86AudioLowerVolume", function () awful.util.spawn_with_shell(voldown) end),
awful.key({                   }, "XF86AudioMute",        function () awful.util.spawn_with_shell(volmute) end),
awful.key({                   }, "XF86AudioMicMute",     function () awful.util.spawn_with_shell(capmute) end),

-- Adjust screen brightness
awful.key({                   }, "XF86MonBrightnessUp",   function () awful.util.spawn_with_shell(lcdup)   end),
awful.key({                   }, "XF86MonBrightnessDown", function () awful.util.spawn_with_shell(lcddown) end),

-- Control mpd
awful.key({                   }, "XF86AudioPrev",        function () awful.util.spawn_with_shell(mpd_prev)   end),
awful.key({                   }, "XF86AudioNext",        function () awful.util.spawn_with_shell(mpd_next)   end),
awful.key({                   }, "XF86AudioPlay",        function () awful.util.spawn_with_shell(mpd_toggle) end),

-- Make PrtSc key usable
awful.key({                   }, "Print", function () awful.util.spawn_with_shell(prtscr) end),

-- Host-specific
awful.key({ modkey,           }, "F4",                   function () awful.util.spawn_with_shell('virt-manager') end),
awful.key({ modkey,           }, "F8",                   function () awful.util.spawn_with_shell('arandr')       end),

-- Drop-down console
awful.key({ modkey            }, "Return", function () awful.screen.focused().quake:toggle() end),

-- Promot: Web search
awful.key({ modkey,           }, "r", function()
    awful.prompt.run {
        prompt       = "Web search: ",
        textbox      = awful.screen.focused().promptbox.widget,
        exe_callback = function(input)
            awful.util.spawn_with_shell("awesomesearch "..input)
        end
    }
end))

--}}}

--{{{ Clients management

-- Clientkeys
clientkeys = awful.util.table.join(
awful.key({ modkey,           }, "t", function (c) c:move_to_screen()              end),
awful.key({ modkey,           }, "f", function (c) c:kill()                        end),
awful.key({ modkey,           }, "d", function (c) c.minimized = not c.minimized   end),
awful.key({ modkey,           }, "a", function (c) c.fullscreen = not c.fullscreen end))
--awful.key({ modkey,           }, "e", function (c)
    --c.maximized_horizontal = not c.maximized_horizontal
    --c.maximized_vertical   = not c.maximized_vertical
--end))

--}}}

--{{{ Tag management

for i = 1, 9 do
    -- Bind all key numbers to tags
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey            }, "#" .. i + 9, function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            tag:view_only()
        end
    end),

    -- Toggle multi-tag view
    awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            awful.tag.viewtoggle(tag)
        end
    end),

    -- Move client among tags
    awful.key({ modkey, "Shift"   }, "#" .. i + 9, function ()
        local tag = client.focus.screen.tags[i]
        if tag then
            client.focus:move_to_tag(tag)
        end
    end),

    -- Make client visible in multi-tags
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function ()
        local tag = client.focus.screen.tags[i]
        if tag then
            client.focus:toggle_tag(tag)
        end
    end))
end

clientbuttons = awful.util.table.join(
awful.button({                   }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey            }, 1, awful.mouse.client.move),
awful.button({ modkey            }, 3, awful.mouse.client.resize))

--}}}

-- Set keys
root.keys(globalkeys)

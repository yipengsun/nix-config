-- module: rules-signals.lua
-- vim:fdm=marker

--{{{ Rules

awful.rules.rules = {
    -- All clients will match these rules
    { rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        } },

    -- Match specific clients
    { rule_any = { class = { "Firefox", "Chromium", "firefox", "Navigator" } },
        properties = { tag = "WWW", maximized = false, maximized_vertical = false, maximized_horizontal = false } },
    { rule = { class = "mpv" },
        properties = { floating = true  } },
    { rule_any = { class = { "Steam", "Logseq" } },
        properties = { tag = "MISC" } },
    { rule_any = { class = { "Mathematica", "XMathematica" } },
        properties = { tag = "CODE" } },
    { rule = { class = "zoom" },
        properties = { tag = "COM" } },

    -- Games

    -- Meta window-types
    { rule = { class = "Dialog" },
        properties = { floating = true  } },

    -- Instance/Name-specific
    { rule = { instance = "plugin-container" },
        properties = { floating = true  } },

    -- Special care for my terminals
    -- { rule = { class = "XTerm" },
    --     callback = function(c)
    --         c:tags({ awful.screen.focused().selected_tag, awful.screen.focused().tags[#awful.screen.focused().tags] }) end },
    { rule_any = { class = { "XTerm", "Alacritty", "org.wezfurlong.wezterm" } },
        callback = awful.client.setslave  },
}

--}}}

--{{{ Signals

-- Signal function to execute when a new client appears
client.connect_signal("manage", function(c)
    if awesome.startup and
        not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- No border when there's only one window
-- for s = 1, screen.count() do screen[s]:connect_signal("arrange",
--     function ()
--         local clients = awful.client.visible(s)
--         local layout  = awful.layout.getname(awful.layout.get(s))

--         if #clients > 0 then -- Fine grained borders and floaters control
--             for _, c in pairs(clients) do -- Floaters always have borders
--                 if awful.client.floating.get(c) or layout == "floating" then
--                     c.border_width = beautiful.border_width

--                     -- No borders with only one visible client
--                 elseif #clients == 1 or layout == "max" then
--                     c.border_width = 0
--                 else
--                     c.border_width = beautiful.border_width
--                 end
--             end
--         end
--     end)
-- end

--}}}

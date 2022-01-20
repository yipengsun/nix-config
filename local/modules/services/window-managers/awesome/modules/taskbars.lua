-- Module: taskbars.lua
-- vim:fdm=marker

require("modules.widgets")

local taglist_buttons = awful.util.table.join(
    awful.button({        }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag))

local tasklist_buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            client.focus = c
            c:raise()
        end),

    awful.button({ }, 3, function ()
            if instance then
                instance:hide()
                instance = nil
            end
        end),

    awful.button({ }, 4, function ()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.button({ }, 5, function ()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end))

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create a promptbox for each screen
    s.promptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which layout we're using
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    s.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wiboxes
    s.taskbar_top    = awful.wibox({ position = "top",    height = "20", screen = s })

    s.taskbar_top:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.taglist,
            spacer,
            s.promptbox,
        },
        --- Middle widgets
        s.tasklist
        ,
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacer,
            thermal_widget,
            spacer,
            cpu_widget,
            spacer,
            mem_widget,
            spacer,
            bat_widget,
            spacer,
            mail_widget,
            spacer,
            textclock,
            ---- Create a systray
            wibox.widget.systray(),
            s.layoutbox,
        },
    }
end)

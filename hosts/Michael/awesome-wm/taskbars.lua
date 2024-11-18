-- module: taskbars.lua
-- vim:fdm=marker

local mk = lain.util.markup
local common = require("awful.widget.common")

--{{{ Widget
-- Spacer
spacer = wibox.widget.textbox()
spacer:set_markup(" - ")

-- Text clock with second display
textclock = wibox.widget.textclock("%a %b %d, %H:%M:%S ", 1)

-- CPU load
cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, "CPU: "..mk.fg.color(beautiful.fg_urgent, "$1%"), 3)

-- CPU temperature
thermal_widget = wibox.widget.textbox()
vicious.register(thermal_widget, vicious.widgets.hwmontemp, "Temp: "..mk.fg.color(beautiful.fg_urgent, "$1°C"), 10, { "k10temp" })

-- Memory
mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, "Mem: "..mk.fg.color(beautiful.fg_urgent, "$2M"), 5)

--}}}

--{{{ Taskbar layout

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


local function list_update(w, buttons, label, data, objects)
    -- call default widget drawing function
    common.list_update(w, buttons, label, data, objects)
    -- set widget size
    w:set_max_widget_size(450)
end

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

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
    s.tasklist = awful.widget.tasklist(
        s, awful.widget.tasklist.filter.currenttags, tasklist_buttons, nil, list_update, wibox.layout.flex.horizontal())

    -- Create a prompt box
    s.mypromptbox = awful.widget.prompt()

    -- Create the wiboxes
    -- Transparent taskbar
    s.taskbar_top = awful.wibar({ position = "top", height = "20", screen = s, bg = "FFFFFF0" })

    s.taskbar_top:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.taglist,
            spacer,
            s.mypromptbox,
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
            textclock,
            wibox.widget.systray(),
            s.layoutbox,
        },
    }
end)

--}}}

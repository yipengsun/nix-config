-- Module: taskbars.lua
-- vim:fdm=marker

--{{{ Widget
-- Spacer
spacer = wibox.widget.textbox()
spacer:set_markup('<span color="'..beautiful.fg_normal..'"> - </span>')

-- Text clock with second display
textclock = wibox.widget.textclock('<span color="'..beautiful.fg_normal..'">%a %b %d, %H:%M:%S </span>', 1)

-- CPU load
cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, '<span color="'..beautiful.fg_normal..'">CPU: </span><span color="'..beautiful.fg_focus..'">$1%</span>', 3)

-- CPU temperature
thermal_widget = wibox.widget.textbox()
vicious.register(thermal_widget, vicious.widgets.hwmontemp, '<span color="'..beautiful.fg_normal..'">Temp: </span><span color="'..beautiful.fg_focus..'">$1°C</span>', 10, { "k10temp" })

-- Memory
mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, '<span color="'..beautiful.fg_normal..'">Mem: </span><span color="'..beautiful.fg_focus..'">$2M</span>', 5)

-- Battery
bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat, '<span color="'..beautiful.fg_normal..'">Bat: </span><span color="'..beautiful.fg_focus..'">$1$2%</span>', 20, "BAT0")

-- Mail
mail_widget = wibox.widget.textbox()
vicious.register(mail_widget, vicious.widgets.mdir, '<span color="'..beautiful.fg_normal..'">Mail: </span><span color="'..beautiful.fg_focus..'">$1</span>', 5, { home_path.."/mail/" })

-- Weather
-- List of city IDs can be downloaded here: http://bulk.openweathermap.org/sample/
weather_widget = lain.widget.weather{
    city_id = 4351977, -- College Park, MD, USA
    settings = function()
        local raw_descr = weather_now["weather"][1]["description"]
        local descr = raw_descr:sub(1, 1):upper()..raw_descr:sub(2)
        local units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(lain.util.markup.fontfg(
            beautiful.font, beautiful.fg_normal, "Weather: "..'<span color="'..beautiful.fg_focus..'">'..descr.." "..units.. "°C </span>"))
    end
}.widget

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

--}}}

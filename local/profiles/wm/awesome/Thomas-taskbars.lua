-- Module: taskbars.lua
-- vim:fdm=marker

local mk = lain.util.markup

--{{{ Widget
-- Spacer
spacer = wibox.widget.textbox()
spacer:set_markup(" - ")

-- Text clock with second display
textclock = wibox.widget.textclock("%a %b %d, %H:%M:%S ", 1)

-- CPU load
cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, "CPU: "..mk.fg.color(beautiful.fg_focus, "$1%"), 3)

-- CPU temperature
thermal_widget = wibox.widget.textbox()
vicious.register(thermal_widget, vicious.widgets.hwmontemp, "Temp: "..mk.fg.color(beautiful.fg_focus, "$1°C"), 10, { "k10temp" })

-- Memory
mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, "Mem: "..mk.fg.color(beautiful.fg_focus, "$2M"), 5)

-- Battery
bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat, "Bat: "..mk.fg.color(beautiful.fg_focus, "$1$2%"), 20, "BAT0")

-- Mail
mail_widget = wibox.widget.textbox()
vicious.register(mail_widget, vicious.widgets.mdir, "Mail: "..mk.fg.color(beautiful.fg_focus, "$1"), 5, { home_path.."/mail/" })

-- Weather
-- List of city IDs can be downloaded here: http://bulk.openweathermap.org/sample/
weather_widget = lain.widget.weather{
    APPID = weather_api_key,
    city_id = city_id_weather,
    settings = function()
        local city_name = weather_now["name"]
        local descr = weather_now["weather"][1]["description"]
        -- local descr = raw_descr:sub(1, 1):upper()..raw_descr:sub(2) -- Make the first letter in upper case
        local temp = math.floor(weather_now["main"]["temp"])
        widget:set_markup("Weather: "..mk.fg.color(beautiful.fg_focus, city_name..", "..descr.." "..temp.."°C"))
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
            weather_widget,
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

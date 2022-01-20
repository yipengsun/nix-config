-- Module: widgets.lua
-- vim:fdm=marker

-- Spacer
spacer = wibox.widget.textbox()
spacer:set_markup('<span color="'..beautiful.fg_normal..'"> - </span>')

-- Text clock with second display
textclock = wibox.widget.textclock('<span color="'..beautiful.fg_normal..'">%a %b %d, %H:%M:%S </span>', 1)

-- CPU load
cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, '<span color="'..beautiful.fg_normal..'">CPU: </span><span color="'..beautiful.fg_focus..'">$1%</span>', 3)

-- CPU temperature
thermal_widget_Thomas = wibox.widget.textbox()
vicious.register(thermal_widget_Thomas, vicious.widgets.hwmontemp, '<span color="'..beautiful.fg_normal..'">Temp: </span><span color="'..beautiful.fg_focus..'">$1°C</span>', 10, { "k10temp" })

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

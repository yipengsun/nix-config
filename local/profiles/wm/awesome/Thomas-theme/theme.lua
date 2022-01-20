-- vim:fdm=marker

local theme = {}

-- Initialize environmental variable
theme_path = cfg_path.."/theme/"

-- Wallpaper
theme.wallpaper = "~/config/awesome/wallpaper"

--{{{ Styles

theme.font = "Dejavu Sans Mono 8"

--Colors
theme.fg_normal   = "#0E0E0E"
theme.fg_focus    = "#FE0000"
theme.fg_urgent   = "#FFFFFF"
theme.fg_minimize = "#DCDCCC"

theme.bg_normal   = "#A4D1EE"
theme.bg_focus    = "#000000"
theme.bg_urgent   = "#BE2612"
theme.bg_minimize = "#767676"

-- Borders
theme.border_width  = "3"
theme.border_normal = "#6F6F6F"
theme.border_focus  = "#DCDCCC"
theme.border_marked = "#0A57EE"

-- Titlebars
--theme.titlebar_bg_focus  = "#303030"
--theme.titlebar_bg_normal = "#303030"
--theme.titlebar_bg_focus  = "#589AC6"
--theme.titlebar_bg_normal = "#589AC6"

--}}}

--{{{ Menu

theme.menu_height = "15"
theme.menu_width  = "100"

--}}}

--{{{ Icons

-- Remove tasklist icons
theme.tasklist_disable_icon = true

-- Taglist
theme.taglist_squares_sel   = theme_path.."misc/squarefz.png"
theme.taglist_squares_unsel = theme_path.."misc/squarez.png"

-- Tasklist
theme.tasklist_floating_icon = theme_path.."misc/squarefz.png"

-- Layout
theme.layout_tile       = theme_path.."layouts/tile.png"
theme.layout_tileleft   = theme_path.."layouts/tileleft.png"
theme.layout_tilebottom = theme_path.."layouts/tilebottom.png"
theme.layout_tiletop    = theme_path.."layouts/tiletop.png"
theme.layout_fairv      = theme_path.."layouts/fairv.png"
theme.layout_fairh      = theme_path.."layouts/fairh.png"
theme.layout_spiral     = theme_path.."layouts/spiral.png"
theme.layout_dwindle    = theme_path.."layouts/dwindle.png"
theme.layout_max        = theme_path.."layouts/max.png"
theme.layout_fullscreen = theme_path.."layouts/fullscreen.png"
theme.layout_magnifier  = theme_path.."layouts/magnifier.png"
theme.layout_floating   = theme_path.."layouts/floating.png"

--}}}

return theme

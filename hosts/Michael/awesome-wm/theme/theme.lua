-- vim:fdm=marker

local theme = {}

-- Initialize environmental variable
theme_path = cfg_path.."/theme/"

-- Wallpaper
theme.wallpaper = cfg_path.."/wallpaper"

--{{{ Styles

theme.font = "Dejavu Sans Mono 8"

--Colors
theme.fg_normal   = "#19344E"
theme.fg_focus    = "#C0BA80"
theme.fg_urgent   = "#3C0C24"
theme.fg_minimize = "#D9D9D9"

theme.bg_normal   = "#78A1BD"
theme.bg_focus    = theme.fg_normal
theme.bg_urgent   = "#C08086"
theme.bg_minimize = "#8086C0"

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

-- Gaps
theme.gap_single_client = true
theme.useless_gap = 6

--}}}

return theme

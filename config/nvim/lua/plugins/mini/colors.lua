local current_theme = {
  bg = "#282828",
  fg = "#d5c4a1",
}

require("mini.hues").setup({
  background = current_theme.bg,
  foreground = current_theme.fg,
  n_hues = 6,
  -- saturation = "medium",
  -- accent = "bg",
})

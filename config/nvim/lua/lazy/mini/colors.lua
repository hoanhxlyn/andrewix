local current_theme = {
  bg = "#11121d",
  fg = "#a0a8cd",
}

require("mini.hues").setup({
  background = current_theme.bg,
  foreground = current_theme.fg,
  n_hues = 6,
  -- saturation = "medium",
  -- accent = "bg",
})

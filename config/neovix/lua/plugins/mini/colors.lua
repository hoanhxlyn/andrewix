local MiniBase16 = require("mini.base16")
local MiniHues = require("mini.hues")
local primary_bg = "#1d2021"
local primary_fg = "#d5c4a1"

if vim.g.mini.use_hue then
  MiniHues.setup({
    background = primary_bg,
    foreground = primary_fg,
    saturation = "medium",
  })
else
  local palette = MiniBase16.mini_palette(primary_bg, primary_fg, 50)
  MiniBase16.setup({
    palette = palette,
    use_cterm = true,
  })
end

local f = io.open(vim.fn.expand("~/.config/stylix/palette.json"))
if not f then return end
local palette = vim.json.decode(f:read("*a"))
f:close()

require("mini.hues").setup({
  background = "#" .. palette.base00,
  foreground = "#" .. palette.base05,
  n_hues = 6,
  -- saturation = "medium",
  -- accent = "bg",
})

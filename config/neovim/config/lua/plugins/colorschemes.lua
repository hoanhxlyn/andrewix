local colorscheme = "catppuccin"
local transparent = true
require("gruvbox").setup({
  contrast = "",
  transparent_mode = transparent,
})
require("gruvbox-material").setup({
  background = {
    transparent = transparent,
  },
})
require("kanagawa").setup({
  theme = "dragon",
  dimInactive = true,
})
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = transparent,
  auto_integrations = true,
  integrations = {
    mini = {
      enabled = true,
      indentscope_color = "lavender",
    },
  },
})
require("tokyonight").setup({
  style = "night",
  transparent = transparent,
  lualine_bold = true,
})
require("rose-pine").setup({
  dark_variant = "moon",
  styles = {
    transparency = transparent,
  },
})

if colorscheme == "mini" then
  vim.cmd.colorscheme("miniwinter")
else
  vim.cmd.colorscheme(colorscheme)
end

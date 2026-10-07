vim.g.start_time = vim.uv.hrtime()

vim.g.noice = false
vim.g.mini = {
  tabline = true,
  animate = true,
  completion = true,
  picks = true,
  show_dotfiles = true,
  notify = true,
  indent = true,
  explorer = true,
  statusline = true,
  clues = true,
  map = true,
  input = true,
  statuscolumn = true,
  colors = true,
}

require("config.options")
require("config.keymaps")
require("config.mininvim")
require("config.autocmds")

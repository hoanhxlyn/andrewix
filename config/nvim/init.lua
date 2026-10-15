require("config")

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

require("config.deps").setup({ import = "lazy" })

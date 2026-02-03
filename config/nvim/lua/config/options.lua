vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.clipboard = "unnamedplus"
-- WSL: no Wayland compositor, so bridge to the Windows clipboard via
-- win32yank (path exported by modules/core/editor/nwm.nix).
if vim.env.WSL_DISTRO_NAME and vim.env.WIN32YANK then
  local y = vim.env.WIN32YANK
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = { ["+"] = y .. " -i --crlf", ["*"] = y .. " -i --crlf" },
    paste = { ["+"] = y .. " -o --lf", ["*"] = y .. " -o --lf" },
    cache_enabled = 0,
  }
end
vim.o.shell = os.getenv("SHELL") or "bash"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.ignorecase = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.breakindent = false
vim.o.inccommand = "nosplit"
vim.o.foldlevel = 99 -- Necessary
vim.o.foldlevelstart = 99
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cmdheight = 0
vim.o.pumheight = 20
vim.o.laststatus = 3
vim.o.signcolumn = "yes"
vim.o.wrap = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.cursorline = true
vim.o.confirm = true
vim.o.formatoptions = "jcroqlnt" -- tcqj
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --vimgrep"
vim.o.scrolloff = 5
vim.o.termguicolors = true
vim.opt.sessionoptions:append("globals") -- scope.nvim keeps its per-tab state in vim.g.ScopeState

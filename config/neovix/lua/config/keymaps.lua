vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<c-a>", "ggVG")
vim.keymap.set("v", "p", [["_dP]])
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "<s-n>", "<s-n>zzzv")
-- vim.keymap.set("n", "<c-d>", "<c-d>zz")
-- vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("n", "]t", ":tabnext<CR>")
vim.keymap.set("n", "[t", ":tabprevious<CR>")
vim.keymap.set("n", "<leader>wq", "<Cmd>q<Cr>", {
  desc = "Window quit",
})

local function yank_path(expand_str, label)
  vim.keymap.set("n", "<leader>y" .. label, function()
    local path = vim.fn.expand(expand_str)
    if path == "" then
      vim.notify("No file path to yank", vim.log.levels.WARN)
      return
    end
    vim.fn.setreg("+", path)
    vim.notify("Yanked: " .. path, vim.log.levels.INFO)
  end, { desc = "Yank " .. label })
end

yank_path("%:p", "current path (full)") -- full path
yank_path("%", "current path (relative)") -- relative path
yank_path("%:p:h", "current directory") -- directory
yank_path("%:t", "current file name") -- filename only

-- Plain scripts in lua/plugins/ (mini.nvim is a start plugin, so no packadd needed).
return {
  "mini",
  virtual = true,
  priority = 1000,
  after = function()
    local mini = vim.g.mini
    local function req(mod, enabled)
      if enabled ~= false then
        require("plugins.mini." .. mod)
      end
    end

    req("basics")
    req("keymap")
    req("icons")
    req("sessions")
    req("clues", mini.clues)
    req("starter")
    req("colors", mini.colors)
    req("notify", mini.notify)
    req("files", mini.explorer)
    req("animate", mini.animate)
    req("input", mini.input)
    req("statuscolumn", mini.statuscolumn)
    req("tabline", mini.tabline)
    req("statusline", mini.statusline)

    require("mini.bufremove").setup()
    require("mini.trailspace").setup()
    require("mini.move").setup()
    require("mini.fuzzy").setup()
    require("mini.bracketed").setup({ treesitter = { suffix = "s" } })
    require("mini.extra").setup()

    req("operators")
    req("git")
    req("ai")
    req("jump")
    req("surround")
    req("comment")
    req("snippets")
    req("completion", mini.completion)
    req("cursorword")
    req("pairs")
    req("hipatterns")
    req("misc")
    req("picks", mini.picks)
    req("visits")
    req("cmdline")
    req("map", mini.map)
    req("indentscope", mini.indent)

    require("plugins.ui2")
  end,
}

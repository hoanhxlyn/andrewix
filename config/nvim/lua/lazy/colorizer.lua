-- rgb()/hsl()/oklch() only; hex stays in mini.hipatterns, tailwind comes from LSP documentColor.
return {
  "nvim-colorizer.lua",
  event = "BufReadPre",
  after = function()
    require("colorizer").setup({
      options = {
        display = { mode = "virtualtext", virtualtext = { char = "󰝤", position = "before" } },
        parsers = {
          css_fn = true,
          hex = { default = false },
          names = { enable = false },
        },
      },
    })
  end,
}

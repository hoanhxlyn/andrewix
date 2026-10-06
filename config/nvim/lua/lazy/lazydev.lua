return {
  "lazydev.nvim",
  event = "DeferredUIEnter",
  after = function()
    require("lazydev").setup({
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
        { path = "wezterm-types", words = { "wezterm" } },
      },
    })
  end,
}
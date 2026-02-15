
require("mason").setup({
  automatic_installation = false,
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

--[[
-- require("mason-tool-installer").setup({
--   ensure_installed = {
--     "tailwindcss",
--     "vtsls",
--     "lua_ls",
--     "stylua",
--     "cspell",
--     "biome",
--     "prettierd",
--     "eslint-lsp",
--     "css_variables",
--     "cssls",
--     "stylelint",
--     "yamlfix",
--     "jsonls",
--     "yamlls",
--     "taplo",
--     "js-debug-adapter",
--     "kdlfmt",
--     "fish_lsp",
--     "shfmt",
--     "alejandra",
--   },
-- })
--]]

require("mason-lspconfig").setup({
  ensure_installed = {},
})

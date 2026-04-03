vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    local valid_oxfmt_config = {
      "oxfmt.json",
      ".oxfmt.json",
      "oxfmt.yaml",
      "oxfmt.yml",
      "oxfmt.toml",
      "oxfmt.config.ts",
    }
    local function has_oxfmt_config()
      for _, config_file in ipairs(valid_oxfmt_config) do
        local path = vim.fn.getcwd() .. "/" .. config_file
        if vim.uv.fs_stat(path) then
          return true
        end
      end
      return false
    end

    require("conform").setup({
      notify_on_error = true,
      default_format_opts = {
        timeout_ms = 1000,
        lsp_format = "fallback",
        stop_after_first = true,
      },
      format_after_save = function(buf)
        return {
          bufnr = buf,
          async = true,
        }
      end,
      formatters_by_ft = {
        markdown = { "markdownlint-cli2" },
        lua = { "stylua" },
        json = { "biome" },
        yaml = { "yamlfix" },
        javascript = { "biome", "oxfmt", "prettierd" },
        typescript = { "biome", "oxfmt", "prettierd" },
        typescriptreact = { "biome", "oxfmt", "prettierd" },
        javascriptreact = { "biome", "oxfmt", "prettierd" },
        css = { "biome", "oxfmt", "prettierd" },
        scss = { "biome", "oxfmt", "prettierd" },
        kdl = { "kdlfmt" },
        sh = { "shfmt" },
        nix = { "alejandra" },
        toml = { "taplo" },
      },
      formatters = {
        biome = {
          require_cwd = true,
        },
        oxfmt = {
          condition = function(_, ctx)
            return has_oxfmt_config()
          end,
        },
        stylua = {},
        yamlfix = {},
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
              return false
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
    })
    local utils = require("config.utils")
    utils.map("n", utils.L("cf"), require("conform").format, "Format buffer (Conform)")
  end,
})

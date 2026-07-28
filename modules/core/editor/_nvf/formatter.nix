{
  lib,
  pkgs,
}: {
  enable = true;
  setupOpts = {
    notify_on_error = true;
    default_format_opts = {
      timeout_ms = 1000;
      lsp_format = "fallback";
      stop_after_first = true;
    };
    formatters_by_ft = {
      just = ["just"];
    };
    formatters = {
      biome = {require_cwd = true;};
      oxfmt = {
        command = lib.getExe pkgs.oxfmt;
        require_cwd = true;
      };
      stylua = {};
      prettier = {
        prepend_args = lib.mkForce (lib.generators.mkLuaInline ''
          function(self, ctx)
            if vim.bo[ctx.buf].filetype == "markdown" then
              return {"--print-width=120", "--prose-wrap=always"}
            end
            return {}
          end
        '');
      };
      markdown-toc = {
        condition = lib.generators.mkLuaInline ''
          function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
            return false
          end
        '';
      };
      markdownlint-cli2 = {
        prepend_args = ["--fix"];
        condition = lib.generators.mkLuaInline ''
          function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end
        '';
      };
    };
  };
}

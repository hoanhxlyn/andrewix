return {
  "nvim-lspconfig",
  event = "BufReadPre",
  keys = {
    { "<leader>ca", function() vim.lsp.buf.code_action() end, desc = "Code action" },
    { "<leader>cd", function() vim.diagnostic.open_float() end, desc = "Code show diagnostic" },
    { "<leader>cr", function() vim.lsp.buf.rename() end, desc = "LSP: rename" },
    { "<s-k>", function() vim.lsp.buf.hover() end, desc = "LSP: hover" },
    { "<c-/>", function() vim.lsp.buf.signature_help() end, mode = "i", desc = "LSP: signature help" },
    { "<leader>cR", function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No active LSP clients", vim.log.levels.WARN)
        return
      end
      vim.ui.select(clients, {
        prompt = "Restart LSP:",
        format_item = function(item)
          return item.name
        end,
      }, function(choice)
        if choice then
          vim.cmd("LspRestart " .. choice.name)
        end
      end)
    end, desc = "LSP: restart" },
    { "<leader>cD", function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No active LSP clients", vim.log.levels.WARN)
        return
      end
      vim.ui.select(clients, {
        prompt = "Disable LSP:",
        format_item = function(item)
          return item.name
        end,
      }, function(choice)
        if choice then
          vim.cmd("LspStop " .. choice.name)
        end
      end)
    end, desc = "LSP: disable" },
  },
  after = function()
    local utils = require("config.utils")

    local capabilities = vim.tbl_extend(
      "force",
      vim.lsp.protocol.make_client_capabilities(),
      {
        textDocument = {
          completion = {
            completionItem = {
              snippetSupport = true,
            },
          },
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      }
    )
    local ok, blink = pcall(require, "blink.cmp")
    if ok and type(blink.get_lsp_capabilities) == "function" then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end
    vim.lsp.config("*", { capabilities = capabilities })

    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = mininvim.icons.error,
          [vim.diagnostic.severity.WARN] = mininvim.icons.warn,
          [vim.diagnostic.severity.INFO] = mininvim.icons.info,
          [vim.diagnostic.severity.HINT] = mininvim.icons.hint,
        },
      },
      virtual_text = {
        source = "if_many",
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    })

    -- Only LSPs whose binaries come from extraBinPath (modules/core/editor/mnw.nix)
    -- Names = lspconfig config names, not binary names (nil_ls→nil, fish_lsp→fish-lsp)
    vim.lsp.enable({
      "nil_ls", "lua_ls", "html", "cssls", "jsonls", "yamlls",
      "tailwindcss", "vtsls", "fish_lsp", "marksman", "taplo", "biome",
    })

    vim.lsp.document_color.enable(true, nil, { style = "󰝤 " })

    utils.patch_lsp_hover()

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "vtsls" then
          utils.map("n", "<leader>co", utils.action("source.organizeImports"), "[TS] Organize imports")
          utils.map("n", "<leader>cv", utils.command("typescript.selectTypeScriptVersion"), "[TS] Select ts version")
        end
        if client and client.name == "tailwindcss" then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("tailwind-canonical-" .. args.buf, { clear = true }),
            buffer = args.buf,
            callback = function()
              local bufnr = vim.api.nvim_get_current_buf()
              local diags = vim.diagnostic.get(bufnr)
              local edits = {}

              for _, diag in ipairs(diags) do
                if diag.code == "suggestCanonicalClasses"
                  or (diag.message and diag.message:match("can be written as"))
                then
                  local old_class, new_class =
                    diag.message:match("The class `([^`]+)` can be written as `([^`]+)`")
                  if old_class and new_class then
                    table.insert(edits, {
                      lnum = diag.lnum,
                      col = diag.col,
                      end_lnum = diag.end_lnum or diag.lnum,
                      end_col = diag.end_col or (diag.col + #old_class),
                      new_class = new_class,
                    })
                  end
                end
              end

              if #edits == 0 then return end

              table.sort(edits, function(a, b)
                if a.lnum ~= b.lnum then return a.lnum > b.lnum end
                return a.col > b.col
              end)

              for _, edit in ipairs(edits) do
                vim.api.nvim_buf_set_text(
                  bufnr, edit.lnum, edit.col, edit.end_lnum, edit.end_col,
                  { edit.new_class }
                )
              end
            end,
          })
        end
      end,
    })
  end,
}

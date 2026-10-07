return {
  "nvim-ufo",
  dependencies = { "promise-async" },
  event = "BufReadPost",
  keys = {
    { "zO", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
    { "zC", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
    { "zi", function() require("ufo").inspect() end, desc = "Ufo: inspect" },
    { "zk", function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, desc = "Peek Folded Lines" },
  },
  after = function()
    vim.o.foldcolumn = "auto"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    require("ufo").setup({
      open_fold_hl_timeout = 150,
      preview = {
        win_config = {
          border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
      },
      provider_selector = function(_, filetype)
        local ftMap = {
          kdl = "treesitter",
          python = "indent",
        }
        return ftMap[filetype] or { "lsp", "indent" }
      end,
      fold_virt_text_handler = function(virt_text, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󱞡 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virt_text) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
    })
  end,
}

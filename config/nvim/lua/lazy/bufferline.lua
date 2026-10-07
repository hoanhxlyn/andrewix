return {
  "bufferline.nvim",
  event = "DeferredUIEnter",
  enabled = not vim.g.mini.tabline,
  keys = {
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>bL", "<cmd>BufferLineCloseRight<cr>", desc = "Delete Buffers to the Right" },
    { "<leader>bH", "<cmd>BufferLineCloseLeft<cr>", desc = "Delete Buffers to the Left" },
    { "<leader>bd", function() require("mini.bufremove").delete() end, desc = "Delete Buffer" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Delete Others Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<leader>bh", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "<leader>bl", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    { "<leader>ba", function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
          require("mini.bufremove").delete(buf, true)
        end
      end
    end, desc = "Delete all buffer" },
    { "<leader>bw", function() require("mini.bufremove").wipeout() end, desc = "Wipeout Buffer" },
  },
  after = function()
    local MiniBufremove = require("mini.bufremove")
    local MiniIcons = require("mini.icons")

    require("bufferline").setup({
      options = {
        always_show_bufferline = true,
        show_close_icon = false,
        show_buffer_close_icons = false,
        separator_style = "thin",
        groups = {
          options = {
            items = {
              require("bufferline.groups").builtin.pinned:with({ icon = mininvim.icons.pin }),
            },
            toggle_hidden_on_enter = true,
          },
        },
        diagnostics = "nvim_lsp",
        close_command = MiniBufremove.delete,
        diagnostics_indicator = function(_, _, diag)
          local icons = mininvim.icons
          local ret = (diag.error and icons.error .. diag.error .. " " or "")
            .. (diag.warning and icons.warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        get_element_icon = function(o)
          return MiniIcons.get("filetype", o.filetype)
        end,
        offsets = not vim.g.mini.explorer and {
          {
            filetype = "snacks_layout_box",
            text = function()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
            end,
            highlight = "Directory",
            text_align = "left",
            separator = true,
          },
        } or {},
      },
    })
  end,
}

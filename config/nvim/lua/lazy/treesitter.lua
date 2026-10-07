local filetypes = {}
for _, lang in ipairs(mininvim.tree_sitters_ensured_install) do
  vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
end

return {
  -- nvim-treesitter: NO lazy (upstream docs)
  {
    "nvim-treesitter",
    after = function()
      require("nvim-treesitter").setup()

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Install Treesitter",
        pattern = filetypes,
        callback = function(ev)
          vim.treesitter.start(ev.buf)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  -- textobjects: lazy on keys
  {
    "nvim-treesitter-textobjects",
    keys = {
      {
        "]f",
        function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
        end,
        desc = "Next function start",
        mode = { "n", "x", "o" },
      },
      {
        "]F",
        function()
          require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
        end,
        desc = "Next function end",
        mode = { "n", "x", "o" },
      },
      {
        "[f",
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
        end,
        desc = "Previous function start",
        mode = { "n", "x", "o" },
      },
      {
        "[F",
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
        end,
        desc = "Previous function end",
        mode = { "n", "x", "o" },
      },
    },
    after = function()
      require("nvim-treesitter-textobjects").setup({
        move = {
          enable = true,
          set_jumps = true,
        },
      })
    end,
  },
  -- treesitter-context: lazy on event
  {
    "nvim-treesitter-context",
    event = "BufReadPost",
    after = function()
      require("treesitter-context").setup({
        mode = "topline",
        max_lines = 3,
      })
    end,
  },
}

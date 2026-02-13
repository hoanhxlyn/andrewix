local utils = require("config.utils")

-- Treesitter and grammars are managed by Nix.
-- We only configure the plugins here.

require("nvim-treesitter").setup({
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
})

require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
	local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	return string.match(filename, ".*mise.*%.toml$") ~= nil
end, {
	force = true,
	all = true,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	callback = function()
		require("nvim-treesitter-textobjects").setup({
			move = {
				enable = true,
				set_jumps = true,
			},
		})

		local tsc = require("treesitter-context")
		tsc.setup({
			mode = "cursor",
			max_lines = 3,
		})
		local ts_text_object = require("nvim-treesitter-textobjects.move")
		utils.map({ "n", "x", "o" }, "]f", function()
			ts_text_object.goto_next_start("@function.outer", "textobjects")
		end, "Next function start")
		utils.map({ "n", "x", "o" }, "]F", function()
			ts_text_object.goto_next_end("@function.outer", "textobjects")
		end, "Next function end")
		utils.map({ "n", "x", "o" }, "[f", function()
			ts_text_object.goto_previous_start("@function.outer", "textobjects")
		end, "Previous function start")
		utils.map({ "n", "x", "o" }, "[F", function()
			ts_text_object.goto_previous_end("@function.outer", "textobjects")
		end, "Previous function end")
	end,
})

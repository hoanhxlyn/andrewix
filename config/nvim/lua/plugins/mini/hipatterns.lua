local hi = require("mini.hipatterns")
local hi_words = MiniExtra.gen_highlighter.words
hi.setup({
	highlighters = {
		fixme = hi_words({ "FIXME", "fixme" }, "MiniHiPatternsFixme"),
		todo = hi_words({ "TODO", "todo" }, "MiniHiPatternsTodo"),
		note = hi_words({ "NOTE", "note", "readme", "README" }, "MiniHiPatternsNote"),
		bug = hi_words({ "BUG", "bug", "HACK", "hack", "hax" }, "MiniHiPatternsHack"),
		hex_color = hi.gen_highlighter.hex_color({ priority = 200 }),
		hex_shorthand = {
			pattern = "()#%x%x%x()%f[^%x%w]",
			group = function(_, _, data)
				---@type string
				local match = data.full_match
				local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
				return hi.compute_hex_color_group("#" .. r .. r .. g .. g .. b .. b, "bg")
			end,
		},
	},
})

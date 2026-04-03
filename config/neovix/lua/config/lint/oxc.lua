local lint = require("lint")
local valid_config_file = {
	"oxlintrc.json",
	".oxlintrc.json",
	"oxlint.config.ts",
}

local function config_path()
	for idx, config_file in pairs(valid_config_file) do
		local path = vim.fn.getcwd() .. "/" .. config_file ---@type string
		if vim.uv.fs_stat(path) then
			return path
		elseif idx == #valid_config_file then
			return nil
		end
	end
end

if config_path() == nil then
	return nil
else
	local should_use = {
		javascript = { "oxlint" },
		typescript = { "oxlint" },
		javascriptreact = { "oxlint" },
		typescriptreact = { "oxlint" },
	}
	for ft, linters in pairs(should_use) do
		if type(lint.linters_by_ft[ft]) == "table" then
			for _, l in ipairs(linters) do
				local found = false
				for _, existing in ipairs(lint.linters_by_ft[ft]) do
					if existing == l then
						found = true
						break
					end
				end
				if not found then
					table.insert(lint.linters_by_ft[ft], l)
				end
			end
		else
			lint.linters_by_ft[ft] = vim.deepcopy(linters)
		end
	end
end

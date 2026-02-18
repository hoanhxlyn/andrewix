local utils = require("config.utils")

-- Diagnostic config
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
			return diagnostic.message
		end,
	},
})

-- Capabilities
local capabilities = vim.tbl_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	vim.g.mini.completion and require("mini.completion").get_lsp_capabilities() or {},
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

-- Set Global LSP Config
utils.setup_lsp({
	capabilities = capabilities,
})

-- LspAttach handles keymaps and navic
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		-- Keymaps
		utils.map("n", utils.L("ca"), vim.lsp.buf.code_action, "Code action", { buffer = args.buf })
		utils.map("n", utils.L("cd"), vim.diagnostic.open_float, "Code show diagnostic", { buffer = args.buf })
		utils.map("n", utils.L("cr"), vim.lsp.buf.rename, "LSP: rename", { buffer = args.buf })

		if client.name == "vtsls" then
			utils.map("n", utils.L("co"), utils.action("source.organizeImports"), "[TS] Organize imports", { buffer = args.buf })
			utils.map(
				"n",
				utils.L("cv"),
				utils.command("typescript.selectTypeScriptVersion"),
				"[TS] Select ts version",
				{ buffer = args.buf }
			)
		end

		utils.map("n", "<s-k>", vim.lsp.buf.hover, "LSP: Hover", { buffer = args.buf })
		utils.map("i", "<c-/", vim.lsp.buf.signature_help, "LSP: Signature help", { buffer = args.buf })

		-- Navic
		if client.server_capabilities.documentSymbolProvider then
			require("nvim-navic").attach(client, args.buf)
		end
	end,
})

-- Enable Servers
local servers = {
	"vtsls",
	"lua_ls",
	"tailwindcss",
	"jsonls",
	"cssls",
	"yamlls",
	"nil_ls",
	"eslint",
	"html",
	"taplo",
}

for _, server in ipairs(servers) do
	local ok, settings = pcall(require, "after.lsp." .. server)
	if ok then
		utils.setup_lsp(server, settings)
	end
	vim.lsp.enable(server)
end

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")

			mason.setup()
			mason_lspconfig.setup({
				ensure_installed = { },
				automatic_installation = false,
			})
		end
	},
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		opts = {}
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		opts = function()
			local cmp = require("cmp")
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
					['<C-d>'] = cmp.mapping.scroll_docs(4),
				}),
				sources = {
					{ name = "nvim_lsp" },
				},
			})
		end,
	},
}

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		picker = {
			enabled = true,
			win = {
				input = {
					keys = {
						["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
						["<Tab>"] = { "list_down", mode = { "i", "n" } },
					},
				},
			},
		},
		statuscolumn = {
			enabled = true,
		},
		git = {
			enabled = true,
		},
		dashboard = {
			enabled = true,
		},
		explorer = {
			enabled = true,
		},
	},
	keys = {
		{ "<leader>ff", function() Snacks.picker.files() end, desc = "Smart Find Files" },
		{ "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
		{ "<leader>fe", function() Snacks.explorer() end, desc = "File Explorer" },
		{ "<leader>cd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
	}
}

local map = function(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
end

vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
		map("n", "<leader>gd", vim.lsp.buf.definition)
		map("n", "<leader>gD", vim.lsp.buf.declaration)
		map("n", "<leader>cr", vim.lsp.buf.rename)
		map("n", "<leader>cf", vim.lsp.buf.format)
		map("n", "<leader>ca", vim.lsp.buf.code_action)
		map("n", "cd", function()
			vim.diagnostic.open_float()
		end)
	end,
})

map("n", "<leader>ww", "<C-w>w")
map("n", "<leader>wv", "<C-w>v")
map("n", "<leader>wh", "<C-w>s")
map("n", "<leader>wc", "<C-w>c")

map({"n", "v"}, "<M-n>", "h")
map({"n", "v"}, "<M-e>", "j")
map({"n", "v"}, "<M-o>", "k")
map({"n", "v"}, "<M-i>", "l")

map("n", "<leader>gb", "<C-o>")

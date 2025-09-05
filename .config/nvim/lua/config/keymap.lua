vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
      local map = function(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
      end

      map("n", "<leader>cr", vim.lsp.buf.rename)
      map("n", "<leader>cf", vim.lsp.buf.format)
      map("n", "<leader>ca", vim.lsp.buf.code_action)
      map("n", "cd", function()
        vim.diagnostic.open_float()
      end)
	end,
})

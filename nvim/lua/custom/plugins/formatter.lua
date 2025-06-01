return {
	"nvimtools/none-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local null_ls = require("null-ls")
		local formatting = null_ls.builtins.formatting

		null_ls.setup({
			sources = {
				formatting.clang_format, -- C/C++
				formatting.black, -- Python
			},
		})

		-- Set keymap for formatting
		vim.keymap.set("n", "<leader>ff", function()
			vim.lsp.buf.format({ async = true })
		end, { desc = "Format current buffer" })
	end,
}

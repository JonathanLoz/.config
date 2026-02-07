-- ~/.config/nvim/lua/custom/plugins/tex.lua
return {
	{
		"let-def/texpresso.vim",
		ft = { "tex" }, -- load only for TeX files
		config = function()
			-- If the texpresso binary isn't on PATH, set it explicitly:
			-- require("texpresso").texpresso_path = "/full/path/to/texpresso"  -- optional

			-- After snippet storms / leaving insert, gently resync the viewer.
			-- There's no :TeXpressoSync command; we just trigger a CursorMoved to refresh.
			local aug = vim.api.nvim_create_augroup("texpressoGroup", { clear = true })
			vim.api.nvim_create_autocmd("InsertLeave", {
				group = aug,
				pattern = "*.tex",
				callback = function()
					vim.cmd("silent! doautocmd <nomodeline> CursorMoved")
				end,
			})
		end,
	},
}

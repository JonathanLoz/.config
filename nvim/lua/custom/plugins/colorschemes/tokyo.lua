return {
	-- Tokyo Night
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		cond = vim.g.setup.colorscheme == "tokyonight",
		config = function()
			require("tokyonight").setup({
				style = "night", -- storm, moon, night, day
				transparent = vim.g.transparent_enabled,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = false },
				},
				-- you can override more colors here…
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}

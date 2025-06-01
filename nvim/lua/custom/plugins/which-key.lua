-- ~/.config/nvim/lua/custom/plugins/which-key.lua
return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = { presets = { operators = false, motions = false } },
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer‑local keymaps",
			},
		},
	},
}

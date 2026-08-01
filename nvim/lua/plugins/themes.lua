-- Switch theme here: "vscode" or "catppuccin-mocha"
local theme = "vscode"

return {
	{
		"LazyVim/LazyVim",
		opts = { colorscheme = theme },
	},
	{
		"Mofiqul/vscode.nvim",
		opts = {
			transparent = true,
			italic_comments = true,
			italic_inlayhints = true,
		},
	},
	{
		"catppuccin/nvim",
		opts = {
			flavour = "mocha",
			transparent_background = true,
			float = { transparent = true },
			term_colors = true,
		},
	},
}

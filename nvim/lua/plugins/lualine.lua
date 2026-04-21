return {
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			opts.options = opts.options or {}

			-- Custom theme based on vscode with darker normal mode text
			local vscode = require "lualine.themes.vscode"
			vscode.normal.a.fg = "#1e1e1e"
			opts.options.theme = vscode

			-- remove date and time from the far-right corner
			opts.sections.lualine_z = {}

			opts.sections.lualine_c = {
				{
					"filename",
					path = 1,
					shorting_target = 0,
					icon = "󰈙 ",
					color = { fg = "green" },
					symbols = {
						modified = "[+]",
						readonly = "[-]",
						unnamed = "[No Name]",
						newfile = "[New]",
					},
				},
			}
		end,
	},
}

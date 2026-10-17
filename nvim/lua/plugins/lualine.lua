return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		opts.sections.lualine_a = { { "mode", color = { fg = "#1e1e1e" } } }
		opts.sections.lualine_c = {
			{ "filename", path = 1, shorting_target = 0, icon = "󰈙 ", color = { fg = vim.g.terminal_color_2 } },
		}
		opts.sections.lualine_z = {} -- remove date and time from the far-right corner
	end,
}

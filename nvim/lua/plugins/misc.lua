return {
	{ "OXY2DEV/markview.nvim", lazy = false },
	{
		"mfussenegger/nvim-lint",
		opts = function(_, opts) opts.linters_by_ft.markdown = {} end,
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = { delay = 0, virt_text_pos = "eol" },
			current_line_blame_formatter = " <author>, <author_time:%R> - <summary>",
		},
	},
	{ "fei6409/log-highlight.nvim", opts = {} },
}

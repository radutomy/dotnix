return {
	{
		"lewis6991/gitsigns.nvim",
		opts = function(_, opts)
			opts.current_line_blame = true
			opts.current_line_blame_opts = vim.tbl_deep_extend("force", opts.current_line_blame_opts or {}, {
				delay = 0,
				virt_text_pos = "eol",
			})
			opts.current_line_blame_formatter = " <author>, <author_time:%R> - <summary>"
		end,
	},
	{
		"fei6409/log-highlight.nvim",
		opts = {},
	},
}

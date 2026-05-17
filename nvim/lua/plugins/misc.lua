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
	{
		"TaDaa/vimade",
		opts = {
			ncmode = "windows",
			fadelevel = 0.5,
			enablefocusfading = true,
			blocklist = {
				block_inactive_floats = function(win, active)
					return not (win.buf_opts.filetype or ""):match "^snacks_picker_"
						and win.win_config.relative ~= ""
						and (win ~= active or win.buf_opts.buftype == "terminal")
				end,
			},
			link = {
				keep_editor_bright_during_lazygit = function(win, active)
					return active.buf_name:match "lazygit$" and win.win_config.relative == ""
				end,
			},
		},
	},
}

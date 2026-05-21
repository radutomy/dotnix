local saved_mouse
return {
	"akinsho/toggleterm.nvim",
	opts = {
		direction = "float",
		dir = vim.fn.getcwd(),
		float_opts = {
			border = "rounded",
		},
		on_open = function(term)
			local k, b = vim.keymap.set, term.bufnr
			k("t", "<C-u>", "<C-\\><C-n><C-u>zz", { buffer = b })
			k("t", "<C-d>", "<Nop>", { buffer = b })
			k("n", "<C-d>", function()
				vim.cmd "normal! \x04zz"
				if vim.fn.line "w$" == vim.fn.line "$" then vim.cmd "startinsert" end
			end, { buffer = b })

			-- Hand mouse off to tmux/wezterm so click+drag selects natively
			-- without dropping nvim out of terminal mode.
			saved_mouse = saved_mouse or vim.o.mouse
			vim.o.mouse = ""
		end,
		on_close = function() vim.o.mouse = saved_mouse end,
	},
}

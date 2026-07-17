return {
	"folke/snacks.nvim",
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "PersistenceLoadPost",
			callback = function()
				Snacks.picker.explorer()
				vim.defer_fn(function() vim.cmd "wincmd l" end, 10)
			end,
		})
	end,
	opts = {
		explorer = {
			trash = false,
		},
		scroll = {
			animate = {
				duration = { step = 20, total = 120 },
				easing = "linear",
			},
		},
		lazygit = {
			config = {
				os = {
					edit = 'nvim --server "$NVIM" --remote-send "<Cmd>close<CR><Cmd>edit {{filename}}<CR>"',
				},
			},
		},
		picker = {
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "i", "n" } },
					},
				},
			},
			formatters = {
				file = {
					filename_first = true,
					truncate = 80, -- path is set to this many characters max
				},
			},
			sources = {
				explorer = {
					auto_close = false, -- Prevent auto-closing when focusing other windows
					jump = { close = false }, -- Don't close when jumping to files
					follow_file = true, -- Automatically reveal current file in explorer
					hidden = true, -- Show hidden files by default
					actions = {
						explorer_clear_selection = function(picker) picker.list:set_selected() end,
						explorer_noop = function() end,
						explorer_quit_without_saving = function() vim.cmd "qa!" end,
						explorer_save_and_quit = function() vim.cmd "wqa!" end,
					},
					layout = {
						hidden = { "input" }, -- Hide the search bar
						layout = {
							width = 0.20, -- 25% of screen width (dynamic)
							-- min_width = 32,
							position = "left",
						},
					},
					win = {
						input = {
							keys = {
								["<C-q>"] = { "explorer_quit_without_saving", mode = { "i", "n" } },
								["<C-s>"] = { "explorer_save_and_quit", mode = { "i", "n" } },
							},
						},
						list = {
							keys = {
								["<Esc>"] = "explorer_clear_selection",
								["<C-n>"] = false,
								["<c-c>"] = "explorer_noop",
								["<C-q>"] = "explorer_quit_without_saving",
								["<C-s>"] = "explorer_save_and_quit",
								["<Tab>"] = false,
								["v"] = { "select_and_next", mode = { "n", "x" } },
								["V"] = { "select_and_prev", mode = { "n", "x" } },
								["q"] = "explorer_noop",
							},
						},
					},
				},
			},
		},
	},
	keys = {
		-- Explorer
		{
			"<leader>e",
			function() Snacks.picker.explorer() end,
			desc = "File Explorer",
		},
		{
			"<leader>fF",
			function() Snacks.picker.files({ cwd = LazyVim.root() }) end,
			desc = "Find Files (Root Dir)",
		},
		{
			"<leader>ff",
			function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end,
			desc = "Find Files (cwd)",
		},
		{
			"<leader><space>",
			function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end,
			desc = "Find Files (cwd)",
		},
	},
}

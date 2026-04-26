return {
	-- Core LSP Config
	{
		"neovim/nvim-lspconfig",
		opts = {
			diagnostics = {
				virtual_text = false,
				signs = { text = { "●", "●", "●", "●" } }, -- error, warn, info, hint
				float = { border = "rounded", source = true, focusable = true },
				severity_sort = true,
			},
			-- Recognize `vim` as a global to suppress undefined-global warnings
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
				},
				-- Disable OmniSharp which comes by default with lang.dotnet
				omnisharp = {
					enabled = false,
				},
			},
		},
		init = function()
			-- Show diagnostics floating window on cursor hover
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function() vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" }) end,
			})
		end,
	},

	-- Add C# Roslyn support
	{
		"seblj/roslyn.nvim",
		ft = "cs",
		lazy = true,
		opts = {
			extensions = {
				razor = {
					enabled = false,
				},
			},
		},
	},
}

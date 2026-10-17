return {
	"neovim/nvim-lspconfig",
	opts = {
		diagnostics = {
			virtual_text = false,
			signs = { text = { "●", "●", "●", "●" } }, -- error, warn, info, hint
			float = { border = "rounded", source = true },
		},
		servers = {
			nil_ls = { settings = { ["nil"] = { nix = { flake = { autoArchive = true } } } } },
			buf_ls = {},
		},
	},
	init = function()
		-- Show diagnostics floating window on cursor hover
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function() vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" }) end,
		})
	end,
}

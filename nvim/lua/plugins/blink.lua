return {
	"saghen/blink.cmp",
	opts = function(_, opts)
		opts.cmdline = { enabled = false }
		opts.keymap = { preset = "super-tab" }
		opts.sources = { default = { "lsp", "path" } }
		opts.completion = {
			menu = { border = "single" },
			documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "single" } },
		}
		return opts
	end,
}

return {
	"saghen/blink.cmp",
	opts = function(_, opts)
		opts.cmdline.enabled = false
		opts.keymap.preset = "super-tab"
		opts.sources.default = { "lsp", "path" }
		opts.completion.menu.border = "single"
		opts.completion.documentation.auto_show_delay_ms = 500
		opts.completion.documentation.window = { border = "single" }
	end,
}

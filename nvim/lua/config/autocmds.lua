-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Auto-reload files changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	callback = function() vim.cmd "checktime" end,
})

-- Always take the on-disk version when a file changed outside Neovim.
vim.api.nvim_create_autocmd("FileChangedShell", {
	callback = function() vim.v.fcs_choice = "reload" end,
})

-- Force kill terminal when :qa
vim.api.nvim_create_autocmd("QuitPre", {
	group = vim.api.nvim_create_augroup("TerminalClose", { clear = true }),
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].buftype == "terminal" and vim.b[buf].terminal_job_id then
				vim.fn.jobstop(vim.b[buf].terminal_job_id)
			end
		end
	end,
	nested = true,
})

vim.api.nvim_del_augroup_by_name "lazyvim_wrap_spell"

-- Auto-reload files changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	callback = function() vim.cmd "checktime" end,
})

-- Always take the on-disk version when a file changed outside Neovim.
vim.api.nvim_create_autocmd("FileChangedShell", {
	callback = function() vim.v.fcs_choice = "reload" end,
})

-- Don't continue comments on a new line
vim.api.nvim_create_autocmd("FileType", {
	callback = function() vim.opt.formatoptions:remove({ "r", "o" }) end,
})

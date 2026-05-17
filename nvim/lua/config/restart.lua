local M = {}

local function restore_last_session()
	require("persistence").load({ last = true })
	vim.notify "Vim restarted"
end

function M.restore_last_session()
	if vim.g.did_very_lazy then
		vim.schedule(restore_last_session)
		return
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		once = true,
		callback = function() vim.schedule(restore_last_session) end,
	})
end

return M

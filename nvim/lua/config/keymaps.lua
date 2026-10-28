-- LSP

-- F1 - Show signature help if inside function call, otherwise show hover docs
vim.keymap.set("n", "<F1>", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local before = line:sub(1, col + 1)
	local parens = 0

	for i = #before, 1, -1 do
		local c = before:sub(i, i)
		if c == ")" then
			parens = parens - 1
		elseif c == "(" then
			parens = parens + 1
			if parens > 0 then return vim.lsp.buf.signature_help() end
		end
	end
	vim.lsp.buf.hover()
end, { desc = "LSP documentation" })

-- F2 - next ERROR
vim.keymap.set(
	"n",
	"<F2>",
	function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
	{ desc = "Go to next error" }
)

-- F3/F4 - Show and copy the full file path / folder location
for key, expr in pairs({ ["<F3>"] = "%:p", ["<F4>"] = "%:p:h" }) do
	vim.keymap.set("n", key, function()
		local path = vim.fn.expand(expr)
		vim.fn.setreg("+", path)
		vim.notify(path)
	end, { desc = "Copy path" })
end

vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename" })

-- Editing

-- Fix indentation for i, a, A and I
for _, key in ipairs({ "i", "a", "A", "I" }) do
	vim.keymap.set(
		"n",
		key,
		function() return vim.fn.trim(vim.fn.getline ".") == "" and '"_cc' or key end,
		{ expr = true }
	)
end

-- Exits insert mode and returns the cursor to the same position it was before insert mode.
vim.keymap.set("i", "<Esc>", "<Esc>`[")

-- Enter / Shift+Enter insert a new line below / above with proper indentation
vim.keymap.set("n", "<CR>", "ox<BS><ESC>", { desc = "󰌑 Insert line below" })
vim.keymap.set("n", "<S-CR>", "Ox<BS><ESC>", { desc = "󰌑 Insert line above" })

-- Toggle comment
vim.keymap.set("n", "f", "gcc", { remap = true, desc = "Comment line" })
vim.keymap.set("x", "f", "gc", { remap = true, desc = "Comment selection" })

-- In normal and visual modes, Ctrl+C yanks either the current line (in normal mode)
-- or the selection (in visual mode) to the system clipboard, trimming leading and trailing whitespace
vim.keymap.set({ "n", "x" }, "<C-c>", function()
	vim.cmd('normal! "+' .. (vim.fn.mode() == "n" and "yy" or "y"))
	vim.fn.setreg("+", vim.fn.getreg("+"):match "^%s*(.-)%s*$")
end)

vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all text" })

-- Navigation

vim.keymap.set("n", "<Tab>", "<cmd>wincmd w<CR>", { desc = "Switch windows" })
vim.keymap.set(
	"n",
	"<C-i>",
	function() vim.api.nvim_feedkeys(vim.keycode "<C-i>", "n", false) end,
	{ desc = "Forward in jumplist" }
)

vim.keymap.set({ "n", "t" }, "<C-space>", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })

-- Misc

-- CTRL D/U 10-line jumps
local function scroll_and_center(dir)
	vim.cmd("normal! 10" .. dir)
	local l, ll, hw = vim.fn.line ".", vim.fn.line "$", vim.fn.winheight(0) / 2
	if (dir == "k" and l > hw and l < ll - hw) or (dir == "j" and l + hw <= ll) then vim.cmd "normal! zz" end
end

vim.keymap.set("n", "<C-u>", function() scroll_and_center "k" end)
vim.keymap.set("n", "<C-d>", function() scroll_and_center "j" end)

vim.keymap.set({ "n", "v", "i", "t" }, "<C-q>", "<cmd>qa!<cr>", { desc = "Quit without saving" })
vim.keymap.set({ "n", "v", "i", "t" }, "<C-s>", "<cmd>wqa!<cr>", { desc = "Save and close all" })

vim.keymap.set("n", ";", ":")

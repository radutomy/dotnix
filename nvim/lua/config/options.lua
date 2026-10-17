-- disable auto comment
vim.cmd [[autocmd FileType * set formatoptions-=ro]]
vim.g.clipboard = "osc52"

local o = vim.opt

o.clipboard = ""
o.swapfile = false
o.wrap = true
o.updatetime = 100
o.pumblend = 0

-- disable built-in completion
o.complete = ""
o.completeopt = ""

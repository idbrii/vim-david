-- Lua has classes, so allow for more folding depth. (+1)
vim.opt_local.foldnestmax = math.max(vim.g.david_foldnestmax + 1, vim.opt_global.foldnestmax:get())

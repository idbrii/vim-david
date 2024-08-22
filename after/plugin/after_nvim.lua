
-- Gogo doesn't seem to work correctly in nvim, but it's really the same as OpenBrowser.
vim.cmd "command! -nargs=1 Gogo OpenBrowser <args>"

if vim.g.loaded_ale then
    -- ale_use_neovim_diagnostics_api sends all ale lint to nvim's diagnostics
    -- which also contains lsp, so populate with that instead.
    vim.cmd "command! -bar ALEPopulateLocList  :lua vim.diagnostic.setloclist({open = true})"
    vim.cmd "command! -bar ALEPopulateQuickfix :lua vim.diagnostic.setqflist({open = true})"
end


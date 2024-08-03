-- Invoked after vimrc is loaded in neovim.
-- File not called nvimrc or polyglot highlights it as vimscript.


-- neovim has UIEnter instead of a gvimrc.
vim.api.nvim_create_augroup("david_vimrc", { clear = true })
vim.cmd.autocmd "david_vimrc UIEnter * runtime gvimrc.vim"

vim.diagnostic.config{
    virtual_text = false,  -- floating text next to code is too noisy.
    underline = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "",
        },
        linehl = {
            [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = 'WarningMsg',
        },
    },
}


-- Neovide {{{
-- Turn down the flash slow cursor anims.
vim.g.neovide_cursor_animation_length = 0.002
vim.g.neovide_position_animation_length = 0.007
vim.g.neovide_scroll_animation_length = 0.007

-- Goneovim {{{

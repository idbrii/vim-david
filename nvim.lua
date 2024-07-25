-- Invoked after vimrc is loaded in neovim.
-- File not called nvimrc or polyglot highlights it as vimscript.


-- neovim has UIEnter instead of a gvimrc.
vim.cmd.autocmd "UIEnter * runtime gvimrc.vim"


-- Neovide {{{
-- Turn down the flash slow cursor anims.
vim.g.neovide_cursor_animation_length = 0.002
vim.g.neovide_position_animation_length = 0.007
vim.g.neovide_scroll_animation_length = 0.007

-- Goneovim {{{

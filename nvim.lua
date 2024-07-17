-- Invoked after vimrc is loaded in neovim.
-- File not called nvimrc or polyglot highlights it as vimscript.

vim = vim or {} -- to silence lint. TODO: how to config lint for nvim?


-- neovim has UIEnter instead of a gvimrc.
vim.cmd.autocmd "UIEnter * runtime gvimrc.vim"


-- Gogo doesn't seem to work correctly in nvim, but it's really the same as OpenBrowser.
vim.cmd "command! -nargs=1 Gogo OpenBrowser <args>"

-- Neovide {{{
-- Turn down the flash slow cursor anims.
vim.g.neovide_cursor_animation_length = 0.007
vim.g.neovide_position_animation_length = 0.007
vim.g.neovide_scroll_animation_length = 0.007

-- Goneovim {{{

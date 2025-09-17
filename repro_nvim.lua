-- Run this file:
--    pushd %USERPROFILE%
--    nvim --clean -u ~/.vim/bundle/aa-david/repro_nvim.lua
--    neovide -- --clean -u ~/.vim/bundle/aa-david/repro_nvim.lua


local cfg_root = "~/nvim_issue_x"



for name, url in pairs {
    sensible = 'https://github.com/tpope/vim-sensible.git',

    mason = 'https://github.com/williamboman/mason.nvim.git',
    mason_lspconfig = 'https://github.com/williamboman/mason-lspconfig.nvim.git',
    lspconfig = 'https://github.com/neovim/nvim-lspconfig.git',

    --~ quicker = 'https://github.com/stevearc/quicker.nvim',
    --~ asyncrun = 'https://github.com/skywind3000/asyncrun.vim',
} do
    local install_path = vim.fn.fnamemodify(cfg_root .. '/pack/minimal/start/' .. name, ':p')
    if vim.fn.isdirectory(install_path) == 0 then
        vim.fn.system { 'git', 'clone', '--depth=1', url, install_path }
    end
end
vim.opt.packpath:append(cfg_root)


-- Personal preference {{1
vim.cmd.colorscheme "desert"
vim.g.mapleader = ' '
vim.o.autochdir = true
vim.o.hidden = false  -- Neovim enables by default, but I don't want unsaved surprises on shutdown.
vim.o.smartcase = true; vim.o.ignorecase = true
vim.o.winborder = 'rounded'  -- Prettier (but bigger) floating windows.
vim.o.wrapscan = true
vim.keymap.set('i', '<C-l>', '<Esc>', { silent = true, })
vim.keymap.set('n', '<Leader>fs', ':<Cmd>update<CR>', { silent = true, })
vim.cmd.source "~/.vim/bundle/aa-david/plugin/config_navigation.vim"

-- nightly workarounds {{{
-- nvim#32411
vim.o.titlestring = '%t%( %M%)%( (%{&ft=="help"?"help":expand("%:p:~:h")})%)%a - '
if vim.v.servername:find('localhost') then
    -- Make it easier to identify my server.
    vim.o.titlestring = vim.o.titlestring .. 'vide'
else
    vim.o.titlestring = vim.o.titlestring .. 'nvim'
end


-- Neovide {{{
-- Turn down the flash slow cursor anims.
vim.g.neovide_cursor_animation_length = 0.002
vim.g.neovide_position_animation_length = 0.007
vim.g.neovide_scroll_animation_length = 0.007


-- TEST CODE {{{


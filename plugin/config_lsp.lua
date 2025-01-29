-- This lua file is nvim-only

-- nvim auto sets omnifunc
--~ set omnifunc=lsp#complete

local lspconfig = require 'lspconfig'
local david = require 'david'
local diag = require 'david.diag'
local slick = require 'david.slick'

-- cmds/mapping        {{{1
--~ local GRP = vim.api.nvim_create_augroup("david_nvimrc", {})

-- nvim maps K for hover, but I use that for docs. Setup my command to show hover so <L>ih works.
vim.api.nvim_create_user_command("HoverUnderCursor", diag.activate_hover, {})

-- Shim some commands provided by vim-lsp.
vim.api.nvim_create_user_command("LspDefinition", function(...) vim.lsp.buf.definition() end, {})
vim.api.nvim_create_user_command("LspReferences", function(...) return vim.lsp.buf.references() end, {})

vim.keymap.set('n', '<Leader>jt', function()
    -- Blank tagfunc to use ctags. nvim autoconfigures tagfunc to use lsp.
    local fn = vim.o.tagfunc
    vim.o.tagfunc = ''
    local success, msg = pcall(slick.normal, "<C-]>")
    vim.o.tagfunc = fn
    if not success then
        -- Try again with lsp.
        success, msg = pcall(slick.normal, "<C-]>")
        if not success then
            msg = msg:gsub("not found", "%0 in ctags or lsp")
            vim.notify(msg, vim.log.levels.ERROR)
        end
    end
end)
vim.keymap.set('n', '<Leader>jT', '<C-]>')
vim.keymap.set('n', '<Leader>jL', vim.lsp.buf.references)


-- lsp config        {{{1
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-nvim-dap").setup()

-- Turn off signs because they're currently too noisy. (Doesn't seem to work.)
-- From :h lsp-handler-configuration
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Disable signs
        signs = false,
    }
)



-- cpp/c        {{{1
-- scoop install llvm
-- Hopefully nvim-lspconfig handles setup for clangd, but installing via scoop gets
-- us clang-format too which ale auto configures.

-- pip install python-lsp-server
-- Hopefully nvim-lspconfig handles setup for pylsp
lspconfig.pylsp.setup{
    --~ cmd = vimlsp_dir .."pylsp-all/pylsp-all.cmd",
    --~ settings = {
    --~     pylsp = {
    --~         --~ plugins = {
    --~         --~     pycodestyle = {
    --~         --~         ignore = {'W391'},
    --~         --~         maxLineLength = 100
    --~         --~     }
    --~         --~ }
    --~     }
    --~ }
}

-- Godot        {{{1
-- brew cask install godot
lspconfig.gdscript.setup{}


-- harper       {{{1
-- Grammar checker
lspconfig.harper_ls.setup {
    settings = {
        ["harper-ls"] = {
            linters = {
                spell_check = false,  -- Doesn't respect my multiple vim dictionaries, so disable.

                -- Disabled due to example code in comments.
                long_sentences = false,  -- Code looks like long sentences.
                sentence_capitalization = false,  -- Code doesn't start with capital.
                spaces = false,  -- Code has lots of spaces.
            },
        },
    },
}


-- lua-lsp        {{{1
-- brew install luarocks
--   or
-- scoop install luarocks # also requires visual studio for cl.exe
-- luarocks install luacheck
-- luarocks install --server=http://luarocks.org/dev lua-lsp

local lua_seen_roots = {}
local function build_nvim_lsp_config()
    return {
        runtime = {
            version = 'LuaJIT',
        },
        workspace = {
            checkThirdParty = false,
            library = {
                -- Make the server aware of Neovim runtime files
                vim.env.VIMRUNTIME,
                -- Depending on the usage, you might want to add additional paths here.
                -- "${3rd}/luv/library"
            },
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
        },
        diagnostics = {
            globals = {
                'vim',
            }
        },
    }
end

-- Currently preferring sumneko because it provides completion my work project,
-- and emmylua no longer provides completion (maybe it only worked in love2d?).
-- TODO: Should I pass lsp this command like I did for gvim: "--metapath ".. vim.g.david_cache_root ..'/lsp/meta'
lspconfig.lua_ls.setup {
    on_new_config = function(cfg, new_root_dir)
        -- We apply different config for different roots, so don't use on_init.
        if vim.loop.fs_stat(new_root_dir..'/.luarc.json')
            or vim.loop.fs_stat(new_root_dir..'/.luarc.jsonc')
        then
            -- Rely on config file if it exists
            return
        end
        -- Called for each file, but only want to load on first in workspace.
        if lua_seen_roots[new_root_dir] then
            return
        end
        lua_seen_roots[new_root_dir] = true

        local valid_paths = {'data', 'scripts'}
        local settings
        if new_root_dir:find("%pvim") then
            settings = build_nvim_lsp_config()
        else
            settings = david.get_sumneko_cfg_from_luacheck(new_root_dir ..'/.luacheckrc', valid_paths)
            if settings then
                settings = settings.Lua
                -- Otherwise it seems to clobber it, and I'll probably look at vim at some point.
                table.insert(settings.diagnostics.globals, "vim")
            end
        end

        if settings then
            -- This *appends* to existing config, so if we default to nvim config above, then we'll already have its settings.
            cfg.settings.Lua = vim.tbl_deep_extend('force', cfg.settings.Lua, settings)
        end
    end,
    settings = {
        Lua = {}
    },
}



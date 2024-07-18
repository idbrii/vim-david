-- This lua file is nvim-only

-- nvim auto sets omnifunc
--~ set omnifunc=lsp#complete

require("mason").setup()
require("mason-lspconfig").setup()
local lspconfig = require 'lspconfig'

-- nvim maps K for hover, but I use that for docs. Setup my command to show hover so <L>ih works.
vim.cmd.command "HoverUnderCursor lua vim.lsp.buf.hover()"



lspconfig.lua_ls.setup {
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
            return
        end

        -- TODO: not certain this is loading correctly. Maybe on_init isn't correct entrypoint.
        local settings = vim.fn.execute('david#lua#lsp#BuildConfigFromLuacheckrc()')
        settings = settings or { -- fallback to config for nvim
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
                    -- "${3rd}/busted/library",
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
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, settings)
    end,
    settings = {
        Lua = {}
    },
}

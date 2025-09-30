-- This lua file is nvim-only

-- nvim auto sets omnifunc
--~ set omnifunc=lsp#complete


local david = require 'david'
local diag = require 'david.diag'
local slick = require 'david.slick'


local function setup_lsp(lsp_id, cfg)
    vim.lsp.enable(lsp_id)
    vim.lsp.config(lsp_id, cfg)
end

local VERSION = vim.version()
if VERSION.major <= 0 and VERSION.minor < 11 then
    -- lspconfig used to do more.
    local lspconfig = require 'lspconfig'
    setup_lsp = function(lsp_id, cfg)
        lspconfig[lsp_id].setup(cfg)
    end
end

local lsp_attach = {}

-- cmds/mapping        {{{1
local GRP = vim.api.nvim_create_augroup("david_lsp", {})

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

local line_length = 200  -- must be obscene to warn.

-- cpp/c        {{{1
-- Install clangd and clang-format via mason. Hopefully ale and lsp don't conflict.
setup_lsp("clangd", {})

function lsp_attach.clangd(args)
    -- Don't add comment highlighting. I'm using clangd with msvc without a
    -- compile_commands.json so it doesn't actually know what defines are set.
    -- Must happen after attach (or FileType?) or it's overwritten.
    vim.api.nvim_set_hl(0, '@lsp.type.comment.cpp', {})
end

-- Python       {{{1
setup_lsp("pylsp", {
    settings = {
        pylsp = {
            plugins = {
                -- pycodestyle is default over flake8, but they're configured the same so just roll with it.
                pycodestyle = {
                    ignore = {
                        'E225',  -- missing whitespace around operator -- I like 'sdf'+ val
                        'E302',  -- expected 2 blank lines, found 1
                        'E402',  -- module level import not at top of file
                        'E501',  -- line too long
                        'W503',  -- line break before binary operator -- my preferred style
                    },

                    -- Minimal set for other people's code.
                    -- https://pycodestyle.readthedocs.io/en/latest/intro.html#error-codes
                    -- Things that are likely bugs (disabled because I don't know how to configure).
                    --~ include = {
                    --~     'C90',  -- mccabe
                    --~     'F',  -- flake errors
                    --~     'E999',  -- SyntaxError
                    --~     'E7',  -- Statement
                    --~     'E9',  -- Runtime error
                    --~     'W6',  -- Deprecation
                    --~     -- Worthwhile style:
                    --~     'E1',  -- Indentation
                    --~     'W291',  -- trailing whitespace
                    --~     'W293',  -- blank line contains whitespace
                    --~ },
                    maxLineLength = line_length,
                },
            },
        },
    },
})

-- Godot        {{{1
-- brew cask install godot
setup_lsp("gdscript", {})


-- harper       {{{1
-- Grammar checker
setup_lsp("harper_ls", {
    filetypes = {
        'gitcommit',
        'html',
        'markdown',
        'text',
        'toml',
        -- Having some random slowdowns while typing, so limiting harper to see if
        -- they go away. False positives in code make it more friction than helpful.
    },
    settings = {
        ["harper-ls"] = {
            linters = { -- https://writewithharper.com/docs/rules
                SpellCheck = false,  -- Doesn't respect my multiple vim dictionaries, so disable.

                AnA = false,  -- I don't always capitalize acronyms (eg, npc).
                DotInitialisms = false,  -- e.g. is too long.
                InflectedVerbAfterTo = false, -- "set to selected state" is common terse form.
                Overall = false,  -- False positives. #1249
                ToDoHyphen = false,  -- Always use todo.
                USUniversities = false,  -- Probably wrong.

                -- Disabled due to example code in comments.
                CapitalizePersonalPronouns = false, -- i is a common variable name.
                CommaFixes = false,  -- Lua often uses commas without following space.
                Dashes = false, -- Lua uses dashes for comments.
                EllipsisLength = false, -- .. is string concat in Lua.
                ExpandDependencies = false,  -- deps is a common variable name.
                ExpandDependency = false,  -- dep is a common variable name.
                ExpandMinimum = false, -- min() is a function.
                ExpandStandardInput = false,  -- stdin is a common variable name.
                ExpandStandardOutput = false,  -- stdout is a common variable name.
                ExpandTimeShorthands = false,  -- Common variable names.
                ExpandWith = false,  -- Dividing width (w/2) is common.
                LongSentences = false,  -- Code looks like long sentences.
                PhrasalVerbAsCompoundNoun = false,  -- Complains about "startup_level".
                SentenceCapitalization = false,  -- Code doesn't start with capital.
                Spaces = false,  -- Code has lots of spaces.
            },
        },
    },
})


-- lua-lsp        {{{1
-- brew install luarocks
--   or
-- scoop install luarocks # also requires visual studio for cl.exe
-- luarocks install luacheck
-- luarocks install --server=http://luarocks.org/dev lua-lsp

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
setup_lsp("lua_ls", {
    on_init = function(client)
        local cfg = client.settings
        local new_root_dir = client.root_dir

        -- Not using `path == vim.fn.stdpath('config')` because I don't keep my config in AppData.
        local is_vim_plugin = new_root_dir and new_root_dir:find("%pvim")

        if not is_vim_plugin  -- luarc from vim plugins are additive.
            and (not new_root_dir  -- nil for fugitive files.
                or vim.uv.fs_stat(new_root_dir ..'/.luarc.json')
                or vim.uv.fs_stat(new_root_dir ..'/.luarc.jsonc'))
        then
            -- Rely on config file if it exists.
            return
        end

        local valid_paths = {'data', 'scripts'}
        local settings
        if is_vim_plugin then
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
            -- This *appends* to existing config, so if we default to nvim
            -- config above, then we'll already have its settings.
            cfg.Lua = vim.tbl_deep_extend('force', cfg.Lua, settings)
        end
    end,
    settings = {
        Lua = {}
    },
})

-- LspAttach {{{1
vim.api.nvim_create_autocmd('LspAttach', {
        group = GRP,
        callback = function(args)
            -- client_id is a number, so we need to do a lookup to get the
            -- name. pattern doesn't work for LspAttach, so presumably you
            -- should have a single LspAttach callback.
            local name = vim.lsp.get_client_by_id(args.data.client_id).name
            local fn = lsp_attach[name]
            if fn then
                fn(args)
            end
        end,
    })


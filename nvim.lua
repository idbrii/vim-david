-- Invoked after vimrc is loaded in neovim.
-- File not called nvimrc or polyglot highlights it as vimscript.

local VERSION = vim.version()

-- neovim has UIEnter instead of a gvimrc.
local GRP = vim.api.nvim_create_augroup("david_nvimrc", { clear = true })
vim.api.nvim_create_autocmd({ "UIEnter" }, {
        pattern = { "*" },
        command = "runtime gvimrc.vim",
        group = GRP,
        nested = true,
    })

local icon = {
    ERROR = "",
    WARN  = "",
    INFO  = "",
    HINT  = "",
    NONE  = " ",
}


local use_my_diagnostic_display = VERSION.major <= 0 and VERSION.minor < 11

vim.diagnostic.config{
    virtual_text = { current_line = true, },  -- floating text only next to current line
    -- Disabled: fake newlines from virtual_lines move code around too much.
    --~ virtual_lines = { current_line = true, },
    update_in_insert = false,  -- Delay to prevent flashing irrelevant errors.
    underline = true,
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icon.ERROR,
            [vim.diagnostic.severity.WARN]  = icon.WARN,
            [vim.diagnostic.severity.INFO]  = icon.INFO,
            [vim.diagnostic.severity.HINT]  = icon.HINT,
        },
        linehl = {
            -- nvim 0.11 does linting when I leave insert mode which flashes
            -- error highlights too much for me.
            --~ [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = 'WarningMsg',
            [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
        },
    },
    float = {
        border = 'rounded',
        source = true,
        header = '',
        prefix = '',
    },
}

if use_my_diagnostic_display then
    require 'david.diag'.show_virtual_text_only_for_current_line()

    -- Show diagnostics when cursor stays still. Not as nice is exmarks
    --~ vim.api.nvim_create_autocmd({ "CursorHold" }, {
    --~         pattern = { "*" },
    --~         callback = function()
    --~             vim.diagnostic.open_float(nil, { focusable = false })
    --~         end,
    --~         group = GRP,
    --~     })
end
-- else: virtual_text.current_line is better

-- Rotate diagnostics when I really want to see more.
vim.keymap.set('n', '<Leader>vd',
    function()
        local cfg = vim.diagnostic.config().virtual_lines
        vim.diagnostic.config({ virtual_lines = not cfg, })
    end,
    {
        desc = 'Toggle diagnostic virtual_lines',
    })


-- Neovim enables by default, but I don't want unsaved surprises on shutdown.
vim.o.hidden = false

-- Prettier (but bigger) floating windows.
vim.o.winborder = 'rounded'

vim.g.quicker_force_full_path_name = false

local quicker = require("quicker")
quicker.setup({
        opts = {
          -- De-colour non matching lines (for log output).
          winhighlight = 'QuickFixTextInvalid:Normal',
        },
        keys = {
            {
                ">",
                function()
                    quicker.expand({ before = 2, after = 2, add_to_existing = true })
                end,
                desc = "Expand quickfix context",
            },
            {
                "<",
                function()
                    quicker.collapse()
                end,
                desc = "Collapse quickfix context",
            },
        },
        on_qf = function(bufnr)
            vim.b.detectindent_has_tried_to_detect = 1
        end,
        edit = {
            enabled = true,          -- Edit the quickfix like a normal buffer.
            autosave = "unmodified", -- Only write unmodified buffers.
        },
        constrain_cursor = false,    -- Constrains to right of the filename and lnum columns.
        max_filename_width = function()
            if vim.g.quicker_force_full_path_name then
                return 1000000
            end
            -- A quarter of screen width, but capped at biggest.
            local biggest = 50
            return math.floor(math.min(biggest, vim.o.columns / 4))
        end,
        -- Aesthetics
        type_icons = {
            E = icon.ERROR,
            W = icon.WARN,
            I = icon.INFO,
            H = icon.HINT,
            N = icon.NONE, -- does N stand for none?
        },
      })

-- LLM {{{
-- Not sure I always want copilot, so it's an opt plugin.

-- Disabled: Annoyed at its tiny barely-helpful suggestions that discourage
-- snippets and whole line matching which usually work better.
--~ vim.cmd.packadd "copilot"
--~ vim.g.copilot_filetypes = {
--~     ["copilot-chat"] = false,  -- shows suggestions but I can't accept (probably mapping CR?)
--~     unite = false,
--~ }

vim.cmd.packadd "copilot-chat"
require("CopilotChat").setup{
    mappings = {
        reset = {
            normal = false, -- default: C-l which is my nohl
            insert = false, -- default: C-l which is my exit insert
        },
        close = {
            normal = 'gq',
        },
    },
}


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

-- Goneovim {{{

-- Invoked after vimrc is loaded in neovim.
-- File not called nvimrc or polyglot highlights it as vimscript.

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

vim.diagnostic.config{
    -- Seems to be no built-in way to easily see the error for a line without virtual text. (Cursor position doesn't work.)
    virtual_text = false,  -- floating text next to code is too noisy. Use CursorHold instead.
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

-- Show diagnostics when cursor stays still.
vim.api.nvim_create_autocmd({ "CursorHold" }, {
        pattern = { "*" },
        callback = function()
            vim.diagnostic.open_float(nil, { focusable = false })
        end,
        group = GRP,
    })

-- Neovim enables by default, but I don't want unsaved surprises on shutdown.
vim.o.hidden = false

-- Prettier (but bigger) floating windows.
vim.o.winborder = 'rounded'

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
vim.cmd.packadd "copilot"
vim.g.copilot_filetypes = {
    unite = false,
}

vim.cmd.packadd "copilot-chat"
require("CopilotChat").setup{}


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

--- Nvim Diagnostics
local diag = {}

function diag.get_diagnostics_for_current_line()
    local bufnr = 0
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    local opts = { ["lnum"] = line_nr }

    return vim.diagnostic.get(bufnr, opts)
end

function diag.activate_hover()
    local diags = diag.get_diagnostics_for_current_line()
    if diags and next(diags) then
        -- Show diagnostics. nvim determines which to show if there are multiple.
        local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
        }
        return vim.diagnostic.open_float(nil, opts)
    else
        -- Show generic hover
        return vim.lsp.buf.hover()
    end
end


return diag

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

function diag.show_virtual_text_only_for_current_line()
    local ns = vim.api.nvim_create_namespace("CurrentLineDiagnostic")
    local hi = { "Error", "Warn", "Info", "Hint" }
    local pad = (" "):rep(8)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            -- Since this only activates in buffers with lsp, I'm okay with
            -- running it on CursorMoved.
            vim.api.nvim_create_autocmd("CursorMoved", {
                buffer = args.buf,
                callback = function()
                    -- Even when curline didn't change since last time, we want to update in
                    -- case we fixed a diagnostic without changing lines.
                    local curline = vim.api.nvim_win_get_cursor(0)[1]
                    pcall(vim.api.nvim_buf_clear_namespace, args.buf, ns, 0, -1)
                    local diagnostics = vim.diagnostic.get(args.buf, { lnum = curline - 1 })
                    local virt_texts = { { pad } }
                    for i, d in ipairs(diagnostics) do
                        -- Trim \r from luacheck messages.
                        local t = { ("■"):rep(i), " ", d.message:gsub("\r", "", 1), " " }
                        table.insert(virt_texts, { table.concat(t), "Diagnostic" .. hi[d.severity] })
                    end
                    vim.api.nvim_buf_set_extmark(args.buf, ns, curline - 1, 0, {
                            virt_text = virt_texts,
                            hl_mode = "combine",
                        })
                end,
            })
        end,
    })
end

return diag

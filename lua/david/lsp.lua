local lsp = {}

-- Show a floating window listing LSP clients attached to the current buffer.
--
-- The last line is a button to run checkhealth to show the full lsp config.
function lsp.show_info_win()
    local buf = vim.api.nvim_get_current_buf()
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    local clients = vim.lsp.get_clients({ bufnr = buf })

    local lines = {}
    -- Map line number (1-indexed) to client name for <CR> handling.
    local client_at_line = {}

    table.insert(lines, ("LSP clients attached to buffer %d"):format(buf, ""))
    table.insert(lines, ("[%s]:"):format(filename))
    table.insert(lines, "")

    if #clients == 0 then
        table.insert(lines, "  (none)")
    else
        for _, client in ipairs(clients) do
            local status = "starting"
            if client:is_stopped() then
                status = "stopped"
            elseif client.initialized then
                status = "running"
            end
            table.insert(lines, ("  %s (id: %d)"):format(client.name, client.id))
            client_at_line[#lines] = client.name
            table.insert(lines, ("    status: %s"):format(status))
            if client.root_dir then
                table.insert(lines, ("    root: %s"):format(client.root_dir))
            end
        end
    end

    table.insert(lines, "")
    table.insert(lines, "  Run checkhealth vim.lsp")

    local checkhealth_line = #lines

    local float_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
    vim.bo[float_buf].modifiable = false
    vim.bo[float_buf].bufhidden = "wipe"

    local ns = vim.api.nvim_create_namespace("david_lspinfo")
    for line_nr, _ in pairs(client_at_line) do
        vim.api.nvim_buf_set_extmark(float_buf, ns, line_nr - 1, 0, { line_hl_group = "Function" })
    end
    vim.api.nvim_buf_set_extmark(float_buf, ns, checkhealth_line - 1, 0, { line_hl_group = "Function" })

    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, #line)
    end
    width = math.max(width + 2, 40)
    local height = #lines

    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)

    local win = vim.api.nvim_open_win(float_buf, true, {
        relative = "win",
        width = width,
        height = height,
        col = math.floor((win_width - width) / 2),
        row = math.floor((win_height - height) / 2),
        style = "minimal",
        border = "rounded",
        title = " LspInfo ",
        title_pos = "center",
    })

    local function CloseWin()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    for _,key in ipairs({ "q", "gq", "<Esc>"}) do
        vim.keymap.set("n", key, CloseWin, {
                buffer = float_buf,
                desc = "Close LspInfo",
            })
    end

    vim.keymap.set("n", "<CR>", function()
        local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
        local client_name = client_at_line[cursor_line]
        if client_name then
            CloseWin()
            vim.api.nvim_feedkeys(":lsp restart " .. client_name, "n", false)
        elseif cursor_line == checkhealth_line then
            CloseWin()
            vim.cmd.checkhealth("vim.lsp")
        end
    end, { buffer = float_buf })
end

return lsp

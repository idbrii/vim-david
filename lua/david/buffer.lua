local buffer = {}


-- Get the current visual selection as text.
--- @return string
function buffer.get_visual_text()
    return table.concat(buffer.get_visual_lines(), "\n")
end

-- Get the current visual selection.
--- @return string[]
function buffer.get_visual_lines()
    local start = "'<"
    local stop = "'>"
    if vim.api.nvim_get_mode().mode == "v" then
        start = "v"
        stop = "."
    end
    return vim.fn.getregion(vim.fn.getpos(start), vim.fn.getpos(stop))
end


-- Usage:
-- local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
-- vim.print(region_to_text(r))
function buffer.region_to_text(region)
    -- Source: https://github.com/neovim/neovim/pull/13896#issuecomment-1621702052
    local text = ''
    local maxcol = vim.v.maxcol
    for line, cols in vim.spairs(region) do
        local endcol = cols[2] == maxcol and -1 or cols[2]
        local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
        text = ('%s%s\n'):format(text, chunk)
    end
    return text
end


return buffer

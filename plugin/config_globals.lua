-- Global functions to use interactively from nvim.

-- So I can :lua pprint(blah)
-- Instead, use: :lua= blah
--~ function pprint(...)
--~     return print(vim.print(...))
--~ end


-- Dump a lua value to a buffer for inspection.
function View(...)
    -- Use a unique filename to avoid opening an existing buffer.
    vim.cmd.vnew("lua output ".. os.time())
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "delete"
    vim.bo.swapfile = false
    vim.cmd.setfiletype("lua")

    -- Use a register to avoid splitting a huge block of text?
    --~ local txt = vim.inspect(v)
    --~ local c_bak = vim.fn.getreg("c")
    --~ vim.fn.setreg("c", txt)
    --~ vim.cmd"put c"
    --~ vim.fn.setreg("c", c_bak)

    local start_line = 0
    local bufnr = vim.fn.bufnr()
    for i=1,select('#', ...) do
        local val = select(i, ...)
        local lines = vim.split(vim.inspect(val), "\n")
        if i == 1 then
            lines[1] = "output = ".. lines[1]  -- make buffer closer to valid lua
        else
            lines[1] = ", ".. lines[1]
        end
        vim.api.nvim_buf_set_lines(bufnr, start_line, -1, false, lines)
        start_line = -1
    end 
end

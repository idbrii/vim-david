local git = {}

function git.ReblameCurrentLine()
    local t = vim.fn.FugitiveResult(vim.fn.bufnr(''))
    if not next(t) then
        return
    end

    -- Metadata is concealed and wrapped in (parens).
    local dest_sha, file, line = vim.fn.getline('.'):match("^(%x+) (.-)%s+[^(]+ %b() (.*)")
    if not dest_sha then
        return
    end

    if not file:find("%a") then
        -- file is only present when there are renames.
        file = t.blame_file
    end

    -- Open new tab because it's much easier to return to blame.
    local fmt = "Gtabedit %s:%s"
    vim.fn.execute(fmt:format(dest_sha, file, dest_sha))
    vim.fn.execute("Gdiff !~")

    -- View the selected line.
    vim.cmd.wincmd"p"
    if dest_sha:len() > 0 then
        vim.fn.search("\\V".. line)
    end
    vim.cmd.normal{ "zz", bang = true }

    return true
end

return git

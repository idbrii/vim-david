
local function Close()
    vim.cmd.close()
end
local close_cfg = {
    buf = 0,
    desc = 'Quick close undotree.',
}
vim.keymap.set('n', 'gq',
    Close,
    close_cfg
    )

-- Use F2 to toggle in and out of undo.
vim.keymap.set('n', 'F2',
    Close,
    close_cfg
    )

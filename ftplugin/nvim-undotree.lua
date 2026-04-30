
vim.keymap.set('n', 'gq',
    function()
        vim.cmd.close()
    end,
    {
        buf = 0,
        desc = 'Quick close undotree.',
    })

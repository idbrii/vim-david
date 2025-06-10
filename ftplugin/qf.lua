
vim.api.nvim_buf_create_user_command(0, "QuickerToggleFullPath",
    function()
        -- See my quicker.setup() that sets up this unofficial variable.
        vim.g.quicker_force_full_path_name = not vim.g.quicker_force_full_path_name
        vim.cmd.Refresh()
    end, {})

-- For some reason, quicker's editor setup fails to set modifiable.
vim.api.nvim_create_autocmd("BufEnter", {
        buffer = vim.fn.bufnr(),
        desc = "Make quickfix modifiable for Quicker.",
        callback = function()
            vim.opt_local.modifiable = true
        end,
    })

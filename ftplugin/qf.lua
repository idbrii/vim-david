
vim.api.nvim_buf_create_user_command(0, "QuickerToggleFullPath",
    function()
        -- See my quicker.setup() that sets up this unofficial variable.
        vim.g.quicker_force_full_path_name = not vim.g.quicker_force_full_path_name
        vim.cmd.Refresh()
    end, {})

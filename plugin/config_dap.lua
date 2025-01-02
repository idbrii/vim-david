local dap = require "dap"

-- Make it easier to autocomplete common commands.
vim.cmd("command! DapBreakpoint DapToggleBreakpoint")

-- Adapters: Debug process launch config {{{1

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

-- Must check:
-- * Script -> Debug -> Debug with External Editor
-- * Editor -> Editor Settings -> Network -> Debug Adapter -> Sync Breakpoints
dap.adapters.godot = {
    type = "server",
    host = "127.0.0.1",
    -- match port the Godot setting: Editor -> Editor Settings -> Network -> Debug Adapter.
    port = 6006,
}

-- Filetypes: Configure file to use adapter {{{1
dap.configurations.gdscript = {
    {
        -- TODO: Haven't got breakpoints working with Godot yet.
        type = "godot",
        request = "launch",
        name = "Launch scene",
        project = "${workspaceFolder}",
        --~ scene = "main|current|pinned|<path>",
    },
}

dap.configurations.cpp = {
    {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
}

-- UI: Interact with debugger {{{1
local dapui = require "dapui"

vim.api.nvim_create_user_command("DapGuiToggle", function(...) return dapui.toggle() end, {})

---@diagnostic disable: missing-parameter
---@diagnostic disable-next-line: missing-parameter
dapui.setup(
    {
        --~ controls = {
        --~     icons = {
        --~         disconnect = "",
        --~         pause = "",
        --~         play = "",
        --~         run_last = "",
        --~         step_back = "",
        --~         step_into = "",
        --~         step_out = "",
        --~         step_over = "",
        --~         terminate = "󰅜",
        --~     },
        --~ },

        floating = {
            mappings = {
                close = { "gq", "<Esc>" }
            }
        },

        --~ mappings = {
        --~     edit = "e",
        --~     expand = { "<CR>", "<2-LeftMouse>" },
        --~     open = "o",
        --~     remove = "d",
        --~     repl = "r",
        --~     toggle = "t"
        --~ },
})

dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end

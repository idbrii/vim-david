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
dapui.setup({
        controls = {
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = "✕",
            },
        },

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


local GRP = vim.api.nvim_create_augroup("david_dap", { clear = true })

local function MakeJump(fn, arg)
    return function()
        fn(arg)
        dap.focus_frame()
        vim.cmd.wincmd "p"
    end
end

-- Map standard debug commands within dap windows.
local function BufferMappings_Global()
    vim.keymap.set("n", "<F5>",  dap.continue,  { buffer = true, desc = "Start debugging" })
    vim.keymap.set("n", "<F10>", dap.step_over, { buffer = true, desc = "Step over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { buffer = true, desc = "Step into" })
end
vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "dapui_*" },
        callback = BufferMappings_Global,
        group = GRP,
    })

local function CleanupWatch(var)
    var = vim.trim(var)
    -- Ignore everything after the first newline.
    local s = var:match("(.-)\n")
    return s or var
end

local function BufferMappings_Scopes()
    vim.keymap.set("n", "p", function()
        -- Guess a bit where we're pasting from.
        local var = CleanupWatch(vim.fn.getreg('"'))
        if var:len() == 0 or var:find("%s") then
            var = CleanupWatch(vim.fn.getreg('0'))
        end
        dapui.elements.watches.add(var)
    end, { buffer = true, desc = "Paste a watch item" })
end
vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "dapui_scopes" },
        callback = BufferMappings_Scopes,
        group = GRP,
    })

local function BufferMappings_Stacks()
    -- In lua, CR is not jumping to the indicated frame. Add a workaround.
    -- They keys match the direction of movement in the displayed stack.
    vim.keymap.set("n", "<C-Up>", MakeJump(dap.down), { buffer = true, desc = "View outside the current frame" })
    vim.keymap.set("n", "<C-Down>", MakeJump(dap.up), { buffer = true, desc = "View deeper in the current frame" })
end
vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "dapui_stacks" },
        callback = BufferMappings_Stacks,
        group = GRP,
    })


vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })

-- Try a leader-based approach.
vim.keymap.set("n", "<Leader>bc", dap.continue,          { desc = "Start debugging" })
vim.keymap.set("n", "<Leader>bj", dap.step_over,         { desc = "Step over" })
vim.keymap.set("n", "<Leader>bl", dap.step_into,         { desc = "Step into" })
vim.keymap.set("n", "<Leader>bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })

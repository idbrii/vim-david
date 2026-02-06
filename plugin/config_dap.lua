local dap = require "dap"
local dapui = require "dapui"
local slick = require "david.slick"


-- Dap mappings {{{1

local DESIRED_LAYOUT = 1  -- Default config has stuff I want on the left. 2 is console and repl.

-- Make it easier to autocomplete common commands.
vim.cmd("command! DapBreakpoint DapToggleBreakpoint")
vim.api.nvim_create_user_command("DapGuiToggle", function(...) return dapui.toggle() end, {})
vim.api.nvim_create_user_command("DapGuiReset", function() dapui.close(); dapui.open(DESIRED_LAYOUT, {reset = true}) end, {})
vim.api.nvim_create_user_command("DapJumpToCurrentLine", dap.focus_frame, {})


local GRP = vim.api.nvim_create_augroup("david_dap", { clear = true })

local function DefineHelp()
    vim.keymap.set("n", "g?", "<Cmd>map <buffer><CR>",  { buffer = true, desc = "Show buffer mappings" })
end

local function JumpToElement(element_name)
    local element = require"dapui".elements[element_name]
    if not element then
        print("[ERROR] Unknown dapui element:", element_name)
        return
    end
    local bufnr = element.buffer()
    local win_ids = vim.fn.win_findbuf(bufnr)
    if next(win_ids) then
        vim.fn.win_gotoid(win_ids[1])
    else
        -- Better to open a float than error.
        --~ print("[ERROR] dapui element not found:", element_name)
        dapui.float_element(element, { enter = true, })
    end
end

local function MakeJump(jump_fn)
    return function()
        local winid = vim.fn.win_getid()
        jump_fn()
        dap.focus_frame()
        vim.api.nvim_set_current_win(winid)
    end
end

-- Map standard debug commands within dap windows.
local function BufferMappings_Global()
    vim.keymap.set("n", "<F5>",  dap.continue,  { buffer = true, desc = "Start debugging" })
    vim.keymap.set("n", "<F10>", dap.step_over, { buffer = true, desc = "Step over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { buffer = true, desc = "Step into" })
    vim.keymap.set("n", "<S-F11>", dap.step_out, { buffer = true, desc = "Step out" })
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

local function AddWatch(word)
    word = CleanupWatch(word)
    dapui.elements.watches.add(word)
end

local function MakeCursorWordWatchFn(pattern)
    return function()
        AddWatch(vim.fn.expand(pattern))
    end
end

local function BufferMappings_Watches()
    vim.keymap.set("n", "p", function()
        -- Guess a bit where we're pasting from.
        local var = CleanupWatch(vim.fn.getreg('"'))
        if var:len() == 0 or var:find("%s") then
            var = CleanupWatch(vim.fn.getreg('0'))
        end
        dapui.elements.watches.add(var)
    end, { buffer = true, desc = "Paste a watch item" })
    DefineHelp()
end
vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "dapui_watches" },
        callback = BufferMappings_Watches,
        group = GRP,
    })


local function BufferMappings_Stacks()
    -- In lua, CR is not jumping to the indicated frame. Add a workaround.
    -- They keys match the direction of movement in the displayed stack.
    vim.keymap.set("n", "<C-Up>", MakeJump(dap.down), { buffer = true, desc = "View outside the current frame" })
    vim.keymap.set("n", "<C-Down>", MakeJump(dap.up), { buffer = true, desc = "View deeper in the current frame" })
    DefineHelp()
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
vim.keymap.set("n", "<Leader>bk", dap.step_out,          { desc = "Step out" })
vim.keymap.set("n", "<Leader>bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<Leader>b<Down>", MakeJump(dap.down), { desc = "View outside the current frame" })
vim.keymap.set("n", "<Leader>b<Up>",   MakeJump(dap.up),   { desc = "View deeper in the current frame" })
vim.keymap.set("n", "<Leader>bw", MakeCursorWordWatchFn("<cword>"), { desc = "Add word to watch" } )
vim.keymap.set("n", "<Leader>bW", MakeCursorWordWatchFn("<cWORD>"), { desc = "Add WORD to watch" } )
vim.keymap.set("x", "<Leader>bw", function()
    local buffer = require "david.buffer"
    local lines = buffer.get_visual_lines() or {}
    if lines[0] then
        AddWatch(lines[0])
    else
        slick.error("Failed to get selection.")
    end
end, { desc = "Add word to watch" } )

local enterable = {
    --~ watches = true, -- disabled to just peek at watches
    repl = true,
    scopes = true, -- too big to be useful without searching inside
    stacks = true,
}
for mapping,element in pairs({
        b = "breakpoints",
        --~ c = "console",
        r = "repl",
        s = "scopes",
        k = "stacks",
        w = "watches",
    })
do
    vim.keymap.set("n", "<Leader>bg".. mapping, function() return JumpToElement(element) end, { desc = "Jump to ".. element })
    vim.keymap.set("n", "<Leader>bG".. mapping, function() return dapui.float_element(element, { enter = enterable[element], }) end, { desc = "Open floating ".. element })
end

-- Adapters: Debug process launch config {{{1

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

-- Must check:
-- * Script -> Debug -> Debug with External Editor.
-- * Editor -> Editor Settings -> Network -> Debug Adapter -> Sync Breakpoints.
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

---@diagnostic disable: missing-fields
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
---@diagnostic enable: missing-fields

dap.listeners.before.attach.dapui_config = function()
    dapui.open(DESIRED_LAYOUT)
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open(DESIRED_LAYOUT)
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end



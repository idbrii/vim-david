-- Start copilot sessions.
--
-- Requirements:
-- * copilot-cli installed and copilot.exe in path
local claudehopper = {}

local cfg = {
    -- Keys to remap to themselves in terminal mode to ignore existing mappings
    -- (because copilot handles them correctly).
    terminal_unmap_keys = {
        "<C-w>",
    },
    terminal_setup_fn = function(bufnr)
        -- C-u/d are useless in copilot since it acts like a tui instead of outputting text.
        vim.api.nvim_buf_set_keymap(bufnr, "t", "<C-u>", "<ScrollWheelUp>", {
                noremap = true,
                desc = "Scroll copilot output up",
            })
        vim.api.nvim_buf_set_keymap(bufnr, "t", "<C-d>", "<ScrollWheelDown>", {
                noremap = true,
                desc = "Scroll copilot output down",
            })
    end,

    -- How to invoke the terminal (a vim command).
    terminal_cmd = "terminal",

    -- How to run copilot (an executable).
    copilot_exe = "copilot",

    default_working_dir = "c:/code/project/",
    default_run_fn = function(opt, cfg)
        vim.cmd.terminal(cfg.default_working_dir .. "bin/game.exe")
    end,
}

local function get_session_dir()
    return vim.fn.expand("~/.copilot/session-state")
end

local function parse_workspace_yaml(filepath)
    local lines = vim.fn.readfile(filepath)
    if not lines or #lines == 0 then return nil end
    local data = {}
    for _, line in ipairs(lines) do
        local key, value = line:match("^(%w[%w_]*):%s*(.+)$")
        if key and value then
            data[key] = value
        end
    end
    return data
end

function claudehopper.get_sessions()
    local session_dir = get_session_dir()
    local yaml_files = vim.fn.glob(
        vim.fn.fnameescape(session_dir) .. "/*/workspace.yaml",
        false,
        true
        )
    local sessions = {}

    for _, yaml_path in ipairs(yaml_files) do
        local data = parse_workspace_yaml(yaml_path)
        if data and data.id then
            table.insert(sessions, {
                    load_id = data.name or data.id,  -- What we pass to copilot.
                    id = data.id,  -- The directory id.
                    summary = data.name or data.summary,
                    cwd = data.cwd,
                    branch = data.branch,
                    updated_at = data.updated_at or "",
                })
        end
    end

    table.sort(sessions, function(a, b)
        return a.updated_at > b.updated_at
    end)

    return sessions
end

function claudehopper.display_name(session)
    if session.summary and session.summary ~= "" then
        return session.summary
    end
    return session.load_id
end

-- Find a session by name or GUID (exact then prefix match).
--- @param query string A partial match for a session name/id.
function claudehopper.find_session(query)
    local sessions = claudehopper.get_sessions()
    local query_lower = query:lower()

    for _, session in ipairs(sessions) do
        local name = claudehopper.display_name(session):lower()
        if session.id == query or name == query_lower then
            return session
        end
    end

    for _, session in ipairs(sessions) do
        local name = claudehopper.display_name(session):lower()
        if name:find(query_lower, 1, true)
            or session.id:find(query, 1, true) then
            return session
        end
    end

    return nil
end

local NEW_SESSION = "[new]"

function claudehopper.complete(arg_lead)
    local sessions = claudehopper.get_sessions()
    local completions = { NEW_SESSION }
    local lead = arg_lead:lower()

    for _, session in ipairs(sessions) do
        local name = claudehopper.display_name(session)
        if lead == "" or name:lower():find(lead, 1, true) then
            table.insert(completions, name)
        end
    end

    return completions
end

local function setup_terminal_keymaps(bufnr)
    assert(bufnr)
    for _, key in ipairs(cfg.terminal_unmap_keys) do
        vim.api.nvim_buf_set_keymap(bufnr, "t", key, key, {
                noremap = true,
                desc = "Pass through to copilot",
            })
    end
    cfg.terminal_setup_fn(bufnr)
end

local function send_session(send_cmd, session)
    vim.cmd.cd{
        args = { vim.fn.fnameescape(cfg.default_working_dir) },
        mods = { silent = true },
    }

    vim.cmd(string.format("%s %s --resume", send_cmd, cfg.copilot_exe))
    setup_terminal_keymaps(vim.api.nvim_get_current_buf())
end

local function open_session(session)
    return send_session(cfg.terminal_cmd, session)
end

local function FormatSession(session)
    local display = claudehopper.display_name(session)
    if session.cwd then
        display = display .. "  [" .. session.cwd .. "]"
    end
    return display
end

local function ValidateSessionId(session_id)
    if type(session_id) == 'string'
        and session_id ~= ""
    then
        return session_id
    end
    return nil
end

function claudehopper.resume(session_id, use_existing_repl)
    -- Instead of trying to manage my own sessions, just rely on copilot's
    -- resume feature.
    if use_existing_repl then
        send_session('ReplSend', nil)
    else
        open_session(nil)
    end
end

local function delete_session(session)
    assert(session and session.id, "Expected session with id")
    local session_path = get_session_dir() .. "/" .. session.id
    local display = claudehopper.display_name(session)
    local confirm = "Yes, delete."
    vim.ui.select({ confirm, "Cancel" }, {
            prompt = string.format("Delete session '%s' last updated %s?", display, session.updated_at),
        },
        function(choice)
            if choice ~= confirm then
                vim.notify("Delete cancelled", vim.log.levels.INFO)
                return
            end
            local ok, err = vim.fn.delete(session_path, "rf")
            if ok ~= 0 then
                vim.notify("Failed to delete session: " .. (err or "unknown error"), vim.log.levels.ERROR)
                return
            end
            vim.notify("Deleted session: " .. display, vim.log.levels.INFO)
        end)
end

function claudehopper.delete(session_id)
    session_id = ValidateSessionId(session_id)
    if not session_id then
        local sessions = claudehopper.get_sessions()
        if #sessions == 0 then
            vim.notify("No copilot sessions found", vim.log.levels.WARN)
            return
        end

        vim.ui.select(sessions, {
                prompt = "Select Copilot session to delete:",
                format_item = FormatSession,
            },
            function(choice)
                if not choice then
                    return
                end
                local session = choice
                if session then
                    delete_session(session)
                end
            end)
        return
    end

    local session = claudehopper.find_session(session_id)
    if not session then
        vim.notify("Session not found: " .. session_id, vim.log.levels.ERROR)
        return
    end

    delete_session(session)
end

function claudehopper.setup(cfg_overrides)
    for key,val in pairs(cfg_overrides or {}) do
        cfg[key] = val
    end
    vim.api.nvim_create_user_command("Claude", function(opt)
        claudehopper.resume(opt.args, opt.bang)
    end, {
        nargs = "?",
        bang = true,
        complete = claudehopper.complete,
        -- Better to use `copilot --resume` if you already have a shell open!
        desc = "Resume a GitHub Copilot CLI session. Use bang to open in existing repl.",
    })
    vim.api.nvim_create_user_command("ClaudeDelete", function(opt)
        claudehopper.delete(opt.args)
    end, {
        nargs = "?",
        complete = claudehopper.complete,
        desc = "Delete a GitHub Copilot CLI session.",
    })
    vim.api.nvim_create_user_command("ClaudeRun", function(opt)
        -- Ideally, you could select from working directories of the claude
        -- sessions, but that's not currently useful to me.
        cfg.default_run_fn(opt, cfg)
    end, {
        desc = "Run primary project.",
    })
end

return claudehopper

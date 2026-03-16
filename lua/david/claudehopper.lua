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

	-- How to invoke the terminal (a vim command).
	terminal_cmd = "terminal",

	-- How to run copilot (an executable).
	copilot_exe = "copilot",
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
				id = data.id,
				summary = data.summary,
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
	return session.id
end

--- Find a session by name or GUID (exact then prefix match).
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
end

local function open_session(session)
	--~ local prev_dir = vim.fn.getcwd()
	local resume = ""
	if session then
		if session.cwd then
			vim.cmd.cd(vim.fn.fnameescape(session.cwd))
		end
		resume = "--resume=" .. session.id
	end
	-- else: Use new session.

	vim.cmd(string.format("%s %s %s", cfg.terminal_cmd, cfg.copilot_exe, resume))
	setup_terminal_keymaps(vim.api.nvim_get_current_buf())
	--~ vim.cmd.cd(vim.fn.fnameescape(prev_dir))
end

function claudehopper.resume(args)
	if args == NEW_SESSION then
		open_session()
		return
	end

	if not args or args == "" then
		local sessions = claudehopper.get_sessions()

		local items = { NEW_SESSION }
		for _, session in ipairs(sessions) do
			table.insert(items, claudehopper.display_name(session))
		end

		vim.ui.select(items, {
			prompt = "Select Copilot session:",
			format_item = function(item)
				if item == NEW_SESSION then
					return item
				end
				for _, session in ipairs(sessions) do
					if claudehopper.display_name(session) == item and session.cwd then
						return item .. "  [" .. session.cwd .. "]"
					end
				end
				return item
			end,
		}, function(choice)
			if not choice then
				return
			end
			if choice == NEW_SESSION then
				open_session()
			else
				local session = claudehopper.find_session(choice)
				if session then
					open_session(session)
				end
			end
		end)
		return
	end

	local session = claudehopper.find_session(args)
	if not session then
		vim.notify("Session not found: " .. args, vim.log.levels.ERROR)
		return
	end

	open_session(session)
end

local function delete_session(session)
	assert(session and session.id, "Expected session with id")
	local session_path = get_session_dir() .. "/" .. session.id
	local display = claudehopper.display_name(session)
    local confirm = "Yes, delete."
	vim.ui.select({ confirm, "Cancel" }, {
		prompt = string.format("Delete session '%s' last updated %s?", display, session.updated_at),
	}, function(choice)
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

function claudehopper.delete(args)
	if not args or args == "" then
		local sessions = claudehopper.get_sessions()
		if #sessions == 0 then
			vim.notify("No copilot sessions found", vim.log.levels.WARN)
			return
		end

		local items = {}
		for _, session in ipairs(sessions) do
			table.insert(items, claudehopper.display_name(session))
		end

		vim.ui.select(items, {
			prompt = "Select Copilot session to delete:",
			format_item = function(item)
				for _, session in ipairs(sessions) do
					if claudehopper.display_name(session) == item and session.cwd then
						return item .. "  [" .. session.cwd .. "]"
					end
				end
				return item
			end,
		}, function(choice)
			if not choice then return end
			local session = claudehopper.find_session(choice)
			if session then
				delete_session(session)
			end
		end)
		return
	end

	local session = claudehopper.find_session(args)
	if not session then
		vim.notify("Session not found: " .. args, vim.log.levels.ERROR)
		return
	end

	delete_session(session)
end

function claudehopper.setup(cfg_overrides)
	for key,val in pairs(cfg_overrides or {}) do
		cfg[key] = val
	end
	vim.api.nvim_create_user_command("Claude", function(cmd_args)
		claudehopper.resume(cmd_args.args)
	end, {
		nargs = "?",
		complete = claudehopper.complete,
		desc = "Resume a GitHub Copilot CLI session.",
	})
	vim.api.nvim_create_user_command("ClaudeDelete", function(cmd_args)
		claudehopper.delete(cmd_args.args)
	end, {
		nargs = "?",
		complete = claudehopper.complete,
		desc = "Delete a GitHub Copilot CLI session.",
	})
end

return claudehopper

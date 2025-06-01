---@diagnostic disable: unused-local
local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

local function workspace_exists(workspace_name)
	local workspaces = mux.get_workspace_names()
	for _, name in ipairs(workspaces) do
		if name == workspace_name then
			return true
		end
	end
	return false
end

local function switch_or_create_workspace(workspace_name, create_function)
	if workspace_exists(workspace_name) then
		mux.set_active_workspace(workspace_name)
	else
		create_function()
	end
end

function M.default()
	local home_path = os.getenv("HOME")
	local config_path = home_path .. "/.config/"
	local workspace_name = "home"

	local tab_1, pane_1, window_1 = mux.spawn_window({
		workspace = workspace_name,
		cwd = home_path,
		position = {
			origin = "MainScreen",
			x = 200,
			y = 300,
		},
	})
	tab_1:set_title("Home")

	local tab_2, pane_2, window_2 = window_1:spawn_tab({
		-- args = { "nvim" }, -- This makes problems - See here: [Unable to find command in PATH when using SpawnCommandInNewWindow set_environment_variables to edit the PATH · Issue #3950 · wez/wezterm](https://github.com/wez/wezterm/issues/3950)
		cwd = config_path .. "nvim",
	})
	tab_2:set_title("Neovim")

	local tab_3, pane_3, window_3 = window_1:spawn_tab({
		-- args = { "nvim" }, -- This makes problems - See here: [Unable to find command in PATH when using SpawnCommandInNewWindow set_environment_variables to edit the PATH · Issue #3950 · wez/wezterm](https://github.com/wez/wezterm/issues/3950)
		cwd = config_path .. "wezterm",
	})
	tab_3:set_title("Wezterm")

	mux.set_active_workspace(workspace_name)

	local gui_window = window_1:gui_window()
	local active_pane = gui_window:active_pane()

	gui_window:perform_action(wezterm.action.ActivateTab(0), active_pane)

	-- gui_window:toggle_fullscreen()
end

function M.private_notes()
	local home_path = os.getenv("HOME")
	local notes_path = home_path .. "/repos/nikbrunner/notes/"
	local workspace_name = "private-notes"

	local function create_workspace()
		local tab_1, pane_1, window_1 = mux.spawn_window({
			workspace = workspace_name,
			cwd = notes_path,
		})
		tab_1:set_title("Private Notes")
		mux.set_active_workspace(workspace_name)
	end
	
	switch_or_create_workspace(workspace_name, create_workspace)
end

function M.work_notes()
	local home_path = os.getenv("HOME")
	local work_notes_path = home_path .. "/repos/nikbrunner/dcd-notes/"
	local workspace_name = "work-notes"

	local function create_workspace()
		local tab_1, pane_1, window_1 = mux.spawn_window({
			workspace = workspace_name,
			cwd = work_notes_path,
		})
		tab_1:set_title("Work Notes")
		mux.set_active_workspace(workspace_name)
	end
	
	switch_or_create_workspace(workspace_name, create_workspace)
end

function M.default_workspace()
	local workspace_name = "default"
	
	local function create_workspace()
		local tab_1, pane_1, window_1 = mux.spawn_window({
			workspace = workspace_name,
			cwd = os.getenv("HOME"),
		})
		tab_1:set_title("Scratchpad")
		mux.set_active_workspace(workspace_name)
	end
	
	switch_or_create_workspace(workspace_name, create_workspace)
end

return M

---@diagnostic disable: unused-local
local Sessionizer = require("sessionizer")
local Util = require("util")
local Workspace = require("workspace")
local sessions = require("sessions")
local FontUtil = require("font-util")

return function(wezterm, config)
	local mux = wezterm.mux
	local action = wezterm.action

	-- Integration with neovim panes
	local function isViProcess(pane)
		-- get_foreground_process_name On Linux, macOS and Windows,
		-- the process can be queried to determine this path. Other operating systems
		-- (notably, FreeBSD and other unix systems) are not currently supported
		-- return pane:get_foreground_process_name():find('n?vim') ~= nil
		-- Use get_title as it works for multiplexed sessions too
		return pane:get_title():find("[nv]?vim") ~= nil or pane:get_title():find("^v%s") ~= nil
	end

	local function isLazyGitProcess(pane)
		return pane:get_title():find("lazygit") ~= nil
	end

	local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
		local vim_pane_changed = false

		if isViProcess(pane) or isLazyGitProcess(pane) then
			local before = pane:get_cursor_position()
			window:perform_action(
				-- This should match the keybinds you set in Neovim.
				action.SendKey({ key = vim_direction, mods = "CTRL" }),
				pane
			)
			wezterm.sleep_ms(100)
			local after = pane:get_cursor_position()

			if before.x ~= after.x and before.y ~= after.y then
				vim_pane_changed = true
			end
		end

		if not vim_pane_changed then
			window:perform_action(action.ActivatePaneDirection(pane_direction), pane)
		end
	end

	wezterm.on("ActivatePaneDirection-right", function(window, pane)
		conditionalActivatePane(window, pane, "Right", "l")
	end)
	wezterm.on("ActivatePaneDirection-left", function(window, pane)
		conditionalActivatePane(window, pane, "Left", "h")
	end)
	wezterm.on("ActivatePaneDirection-up", function(window, pane)
		conditionalActivatePane(window, pane, "Up", "k")
	end)
	wezterm.on("ActivatePaneDirection-down", function(window, pane)
		conditionalActivatePane(window, pane, "Down", "j")
	end)

	config.bypass_mouse_reporting_modifiers = "CMD"

	config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 1000 }

	config.keys = {

		{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
		{ key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen },

		-- Leader key actions
		{ key = "f", mods = "LEADER", action = FontUtil.selector_action() },

		-- Direct workspace access (universal)
		{
			key = "0",
			mods = "LEADER",
			action = wezterm.action_callback(function()
				sessions.default_workspace()
			end),
		},
		{
			key = "1",
			mods = "LEADER",
			action = wezterm.action_callback(function()
				sessions.private_notes_workspace()
			end),
		},
		{
			key = "2",
			mods = "LEADER",
			action = wezterm.action_callback(function()
				sessions.work_notes_workspace()
			end),
		},
		{ key = "3", mods = "LEADER", action = sessions.dynamic_workspace_action(3) },
		{ key = "4", mods = "LEADER", action = sessions.dynamic_workspace_action(4) },
		{ key = "5", mods = "LEADER", action = sessions.dynamic_workspace_action(5) },
		{ key = "6", mods = "LEADER", action = sessions.dynamic_workspace_action(6) },
		{ key = "7", mods = "LEADER", action = sessions.dynamic_workspace_action(7) },
		{ key = "8", mods = "LEADER", action = sessions.dynamic_workspace_action(8) },
		{ key = "9", mods = "LEADER", action = sessions.dynamic_workspace_action(9) },

		-- Additional Leader actions
		{ key = "r", mods = "LEADER", action = action.ReloadConfiguration },
		{ key = "?", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "FUZZY|KEY_ASSIGNMENTS" }) },

		-- System Level
		{ key = ";", mods = "CMD", action = action.ActivateCommandPalette },
		{ key = "f", mods = "CMD", action = action.Search({ CaseSensitiveString = "" }) },
		{ key = "Escape", mods = "ALT", action = action.ActivateCopyMode },
		{ key = "d", mods = "ALT", action = action.ShowDebugOverlay },
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = action.Multiple({
				action.ClearScrollback("ScrollbackAndViewport"),
				action.SendKey({ key = "L", mods = "CTRL" }),
			}),
		},

		{
			key = "g",
			mods = "ALT",
			action = wezterm.action_callback(function(gui_win, gui_pane)
				local screens = wezterm.gui.screens()
				local active_screen = screens.active
				local tab, pane, window = mux.spawn_window({
					args = { os.getenv("SHELL"), "-c", "lazygit" },
					cwd = Util.get_cwd_from_pane(gui_pane),
					position = {
						origin = "MainScreen",
						x = active_screen.x,
						y = active_screen.y,
						height = active_screen.height,
						width = active_screen.width,
					},
				})
			end),
		},

		-- Workspace Management
		-- macOS direct access (optional enhancement)
		{ key = "0", mods = "CMD", action = wezterm.action_callback(function()
			sessions.default_workspace()
		end) },
		{
			key = "1",
			mods = "CMD",
			action = wezterm.action_callback(function()
				sessions.private_notes_workspace()
			end),
		},
		{
			key = "2",
			mods = "CMD",
			action = wezterm.action_callback(function()
				sessions.work_notes_workspace()
			end),
		},
		{ key = "3", mods = "CMD", action = sessions.dynamic_workspace_action(3) },
		{ key = "4", mods = "CMD", action = sessions.dynamic_workspace_action(4) },
		{ key = "5", mods = "CMD", action = sessions.dynamic_workspace_action(5) },
		{ key = "6", mods = "CMD", action = sessions.dynamic_workspace_action(6) },
		{ key = "7", mods = "CMD", action = sessions.dynamic_workspace_action(7) },
		{ key = "8", mods = "CMD", action = sessions.dynamic_workspace_action(8) },
		{ key = "9", mods = "CMD", action = sessions.dynamic_workspace_action(9) },

		-- Projects & Workspaces
		{ key = "s", mods = "ALT", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{
			key = "s",
			mods = "ALT|SHIFT",
			action = wezterm.action_callback(function(win, pane)
				Sessionizer.toggle(win, pane)
				Sessionizer.refreshCache()
			end),
		},
		{
			key = "o",
			mods = "ALT",
			action = wezterm.action_callback(function(window, pane)
				Workspace.switch_to_previous(window, pane)
			end),
		},
		-- { key = "k", mods = "ALT", action = act.SwitchWorkspaceRelative(-1) },
		-- { key = "j", mods = "ALT", action = act.SwitchWorkspaceRelative(1) },

		-- Tabs, Splits & Windows
		{ key = "r", mods = "ALT", action = action.ShowTabNavigator },
		{
			key = "n",
			mods = "LEADER",
			action = action.PromptInputLine({
				description = "Enter new name for tab",
				---@diagnostic disable-next-line: unused-local
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{
			key = "N",
			mods = "LEADER",
			action = action.PromptInputLine({
				description = "Enter new name for Workspace",
				---@diagnostic disable-next-line: unused-local
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
					end
				end),
			}),
		},

		-- Tab Management
		{ key = "1", mods = "ALT", action = action.ActivateTab(0) },
		{ key = "2", mods = "ALT", action = action.ActivateTab(1) },
		{ key = "3", mods = "ALT", action = action.ActivateTab(2) },
		{ key = "4", mods = "ALT", action = action.ActivateTab(3) },
		{ key = "5", mods = "ALT", action = action.ActivateTab(4) },
		{ key = "6", mods = "ALT", action = action.ActivateTab(5) },
		{ key = "7", mods = "ALT", action = action.ActivateTab(6) },
		{ key = "8", mods = "ALT", action = action.ActivateTab(7) },
		{ key = "9", mods = "ALT", action = action.ActivateTab(8) },
		{ key = "h", mods = "ALT", action = action({ ActivateTabRelative = -1 }) },
		{ key = "l", mods = "ALT", action = action({ ActivateTabRelative = 1 }) },
		{ key = "c", mods = "ALT", action = action.SpawnTab("CurrentPaneDomain") },
		{ key = "x", mods = "ALT", action = action.CloseCurrentTab({ confirm = true }) },
		{ key = ",", mods = "ALT", action = action.MoveTabRelative(-1) },
		{ key = ".", mods = "ALT", action = action.MoveTabRelative(1) },

		-- Workspace Navigation
		{ key = "j", mods = "ALT", action = action.SwitchWorkspaceRelative(-1) },
		{ key = "k", mods = "ALT", action = action.SwitchWorkspaceRelative(1) },

		-- Application Integration (CTRL - vim navigation)
		{ key = "h", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-left") },
		{ key = "j", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-down") },
		{ key = "k", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-up") },
		{ key = "l", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-right") },

		-- Pane Management (Splits)
		{ key = "l", mods = "ALT|SHIFT", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "j", mods = "ALT|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "z", mods = "ALT|SHIFT", action = action.TogglePaneZoomState },
		{ key = "x", mods = "ALT|SHIFT", action = action.CloseCurrentPane({ confirm = true }) },

		-- Pane Resizing
		{ key = "h", mods = "ALT|SHIFT|CTRL", action = action.AdjustPaneSize({ "Left", 10 }) },
		{ key = "j", mods = "ALT|SHIFT|CTRL", action = action.AdjustPaneSize({ "Down", 10 }) },
		{ key = "k", mods = "ALT|SHIFT|CTRL", action = action.AdjustPaneSize({ "Up", 10 }) },
		{ key = "l", mods = "ALT|SHIFT|CTRL", action = action.AdjustPaneSize({ "Right", 10 }) },

		-- Emoji Picker
		{
			key = "u",
			mods = "SHIFT|CTRL",
			action = action.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
		},
	}
end

local Wezterm = require("wezterm")

-- Source: https://github.com/tjex/wezterm-conf/blob/main/functions/funcs.lua#L79
local M = {}

function M.switch(window, pane, workspace)
	if type(workspace) == "string" then
		workspace = { name = workspace }
	end

	local current_workspace = window:active_workspace()

	if current_workspace == workspace then
		return
	end

	-- Update the previous workspace variable before switching
	Wezterm.GLOBAL.previous_workspace = current_workspace

	window:perform_action(Wezterm.action.SwitchToWorkspace(workspace), pane)
end

function M.switch_to_previous(window, pane)
	local current_workspace = window:active_workspace()
	local workspace = Wezterm.GLOBAL.previous_workspace

	if current_workspace == workspace or Wezterm.GLOBAL.previous_workspace == nil then
		Wezterm.log_info("No previous workspace to switch to")
		return
	end

	M.switch(window, pane, workspace)
end

return M

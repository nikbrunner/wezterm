-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function get_time()
	return os.date("%H:%M")
end

---@diagnostic disable-next-line: unused-local
return function(wezterm, config)
	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = true

	wezterm.on("update-right-status", function(window, pane)
		local workspace = window:active_workspace()
		local time = get_time()
		window:set_right_status(workspace .. " | " .. time .. "  ")
	end)

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local title = ""

		if tab.tab_title and #tab.tab_title > 0 then
			title = tab.tab_title
		else
			title = basename(tab.active_pane.foreground_process_name)
		end

		-- Add 1 to make it 1-indexed for display
		local index = tab.tab_index + 1

		return {
			{ Text = " " .. index .. ": " .. title .. " " },
		}
	end)
end

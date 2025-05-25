local function getColorByKey(wezterm, window)
	return wezterm.color.get_builtin_schemes()[window:effective_config().color_scheme]
end

local vin_config_colorscheme = "Black Atom — JPN ∷ Koyo Yoru"

---[Default Key Assignments - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/config/default-keys.html)
---[Color Schemes - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/colorschemes/index.html)
---@diagnostic disable-next-line: unused-local
return function(wezterm, config)
	-- Store the current colorscheme in a global variable
	wezterm.on("window-config-reloaded", function(window, pane)
		local effective_config = window:effective_config()
		local colorscheme = effective_config.color_scheme
		local colorschemes = effective_config.color_schemes

		local local_colorscheme = colorschemes[colorscheme]
		local colors

		if local_colorscheme == nil then
			colors = effective_config.resolved_palette
		else
			colors = colorschemes[colorscheme]
		end

		wezterm.GLOBAL.current_colors = colors
	end)

	config.color_scheme = vin_config_colorscheme
	-- config.colors = {
	-- 	background = "#000000",
	-- 	tab_bar = {
	-- 		background = "#000000",
	-- 	},
	-- }

	config.tab_bar_at_bottom = true

	config.inactive_pane_hsb = {
		saturation = 1,
		brightness = 1,
	}

	config.initial_rows = 500
	config.initial_cols = 500

	config.max_fps = 120

	-- config.window_background_opacity = 0.9
	-- config.macos_window_background_blur = 25

	config.window_decorations = "RESIZE"

	config.window_padding = {
		left = 25,
		right = 25,
		top = 25,
		bottom = 15,
	}

	config.front_end = "WebGpu"

	config.hyperlink_rules = wezterm.default_hyperlink_rules()

	table.insert(config.hyperlink_rules, {
		regex = [[\b(BCD-\d{4})\b]],
		format = "https://dcd.myjetbrains.com/youtrack/issue/$1",
	})

	table.insert(config.hyperlink_rules, {
		regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
		format = "https://www.github.com/$1/$3",
	})

	require("tabs")(wezterm, config)
	-- require("wallpaper")(wezterm, config)
end

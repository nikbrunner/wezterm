local wezterm = require("wezterm")

local M = {
	schemes = {},
}

function M.load_schemes()
	local colors_dir = wezterm.config_dir .. "/colors"
	local schemes = {}
	
	-- Get all TOML files in colors directory
	for _, path in ipairs(wezterm.glob(colors_dir .. "/*.toml")) do
		local file = io.open(path, "r")
		if file then
			local content = file:read("*a")
			file:close()
			
			-- Parse the name from metadata section
			local name = content:match('name%s*=%s*"([^"]+)"')
			if name then
				local filename = path:match("([^/]+)%.toml$")
				schemes[name] = {
					name = name,
					file = filename,
					path = path,
				}
			end
		end
	end
	
	-- Also include built-in schemes
	for name, _ in pairs(wezterm.color.get_builtin_schemes()) do
		schemes[name] = {
			name = name,
			builtin = true,
		}
	end
	
	M.schemes = schemes
	return schemes
end

function M.selector_action()
	return wezterm.action_callback(function(window, pane)
		M.load_schemes()
		
		local custom_choices = {}
		local builtin_choices = {}
		
		for _, scheme in pairs(M.schemes) do
			local label = scheme.name
			local choice = { 
				label = label,
				id = scheme.name 
			}
			
			if scheme.builtin then
				choice.label = label .. " (builtin)"
				table.insert(builtin_choices, choice)
			else
				table.insert(custom_choices, choice)
			end
		end
		
		-- Sort each group alphabetically
		table.sort(custom_choices, function(a, b)
			return a.label < b.label
		end)
		table.sort(builtin_choices, function(a, b)
			return a.label < b.label
		end)
		
		-- Combine with custom themes first
		local choices = {}
		for _, choice in ipairs(custom_choices) do
			table.insert(choices, choice)
		end
		for _, choice in ipairs(builtin_choices) do
			table.insert(choices, choice)
		end

		window:perform_action(
			wezterm.action.InputSelector({
				action = wezterm.action_callback(function(window, pane, id, label)
					if id then
						local overrides = window:get_config_overrides() or {}
						overrides.color_scheme = id
						window:set_config_overrides(overrides)
					end
				end),
				title = "Color Scheme Selector",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

return M
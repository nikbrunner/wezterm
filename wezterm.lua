local wezterm = require("wezterm") --[[@as Wezterm]]
local mux = wezterm.mux
local sessions = require("sessions")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

---@diagnostic disable-next-line: unused-local
local is_mac = wezterm.target_triple:find("darwin")

config.set_environment_variables = {
	EDITOR = "nvim",
	PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
}

config.use_dead_keys = true
-- config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

require("font")(wezterm, config)
require("ui")(wezterm, config)
require("keymaps")(wezterm, config)

wezterm.on("gui-startup", function()
	sessions.default_workspace()
	sessions.private_notes()
	sessions.work_notes()
	mux.set_active_workspace("default")
end)

return config

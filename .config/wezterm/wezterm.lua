local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

wezterm.on("augment-command-palette", function(_, _)
	return {
		{
			brief = "Rename tab",
			icon = "md_rename_box",

			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, _, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	}
end)

wezterm.on("user-var-changed", function(window, pane, name, value)
	wezterm.log_info("var", name, value)
end)

wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.colors = {
	tab_bar = {
		background = "#98c379",
		active_tab = {
			bg_color = "#98c379",
			fg_color = "#3d4840",
			intensity = "Bold",
			italic = true,
		},
		inactive_tab = {
			-- bg_color = "#627e4e",
			bg_color = "#98c379",
			fg_color = "#3d4840",
		},
		inactive_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#909090",
			-- bg_color = "#98c379",
			-- fg_color = "#3d4840",
			italic = true,
		},
		new_tab = {
			bg_color = "#98c379",
			fg_color = "#808080",
		},
		new_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#909090",
		},
	},
}
config.color_scheme = "OneHalfDark"
config.default_domain = "WSL:Ubuntu"
config.font = wezterm.font("MonoLisa Variable")
config.font_size = 11.0
config.window_decorations = "RESIZE|TITLE"
config.window_frame = {
	active_titlebar_bg = "black",
}
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

require("tabs").setup(config)
require("keys").setup(config)

return config

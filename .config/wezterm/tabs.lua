local w = require("wezterm")

local M = {}

M.arrow_solid = ""
M.arrow_thin = ""
M.icons = {
  ["C:\\WINDOWS\\system32\\cmd.exe"] = w.nerdfonts.md_console_line,
  ["Topgrade"] = w.nerdfonts.md_rocket_launch,
  ["bash"] = w.nerdfonts.cod_terminal_bash,
  ["btm"] = w.nerdfonts.mdi_chart_donut_variant,
  ["cargo"] = w.nerdfonts.dev_rust,
  ["curl"] = w.nerdfonts.mdi_flattr,
  ["docker"] = w.nerdfonts.linux_docker,
  ["docker-compose"] = w.nerdfonts.linux_docker,
  ["fish"] = w.nerdfonts.md_fish,
  ["gh"] = w.nerdfonts.dev_github_badge,
  ["git"] = w.nerdfonts.dev_git,
  ["go"] = w.nerdfonts.seti_go,
  ["htop"] = w.nerdfonts.md_chart_areaspline,
  ["ipython"] = w.nerdfonts.dev_python,
  ["btop"] = w.nerdfonts.md_chart_areaspline,
  ["kubectl"] = w.nerdfonts.linux_docker,
  ["kuberlr"] = w.nerdfonts.linux_docker,
  ["lazydocker"] = w.nerdfonts.linux_docker,
  ["lua"] = w.nerdfonts.seti_lua,
  ["make"] = w.nerdfonts.seti_makefile,
  ["node"] = w.nerdfonts.mdi_hexagon,
  ["nvim"] = w.nerdfonts.custom_vim,
  ["pacman"] = "󰮯 ",
  ["paru"] = "󰮯 ",
  ["psql"] = w.nerdfonts.dev_postgresql,
  ["pwsh.exe"] = w.nerdfonts.md_console,
  ["python"] = w.nerdfonts.dev_python,
  ["ruby"] = w.nerdfonts.cod_ruby,
  ["sudo"] = w.nerdfonts.fa_hashtag,
  ["vim"] = w.nerdfonts.custom_vim,
  ["wget"] = w.nerdfonts.mdi_arrow_down_box,
  ["zsh"] = w.nerdfonts.dev_terminal,
  ["lazygit"] = w.nerdfonts.cod_github,
}

---@param tab MuxTabObj
---@param max_width number
function M.title(tab, max_width)
  local title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
  local process, other = title:match("^(%S+)%s*%-?%s*%s*(.*)$")

  w.log_info("process: ", process)
  w.log_info("other: ", other)

  if M.icons[process] then
    title = M.icons[process] .. " " .. (other or "")
  end

  local is_zoomed = false
  for _, pane in ipairs(tab.panes) do
    if pane.is_zoomed then
      is_zoomed = true
      break
    end
  end
  if is_zoomed then -- or (#tab.panes > 1 and not tab.is_active) then
    title = " " .. title
  end

  title = w.truncate_right(title, max_width - 3)
  return " " .. title .. " "
end

---@param config Config
function M.setup(config)
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.hide_tab_bar_if_only_one_tab = false
  config.tab_max_width = 32
  config.unzoom_on_switch_pane = true

  w.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = M.title(tab, max_width)
    local colors = config.resolved_palette
    local active_bg = colors.tab_bar.active_tab.bg_color
    local inactive_bg = colors.tab_bar.inactive_tab.bg_color

    local tab_idx = 1
    for i, t in ipairs(tabs) do
      if t.tab_id == tab.tab_id then
        tab_idx = i
        break
      end
    end
    local is_last = tab_idx == #tabs
    local next_tab = tabs[tab_idx + 1]
    local next_is_active = next_tab and next_tab.is_active
    local arrow = (tab.is_active or is_last or next_is_active) and M.arrow_solid or M.arrow_thin
    local arrow_bg = inactive_bg
    local arrow_fg = colors.tab_bar.inactive_tab_edge

    if is_last then
      arrow_fg = tab.is_active and active_bg or inactive_bg
      arrow_bg = colors.tab_bar.background
    elseif tab.is_active then
      arrow_bg = inactive_bg
      arrow_fg = active_bg
    elseif next_is_active then
      arrow_bg = active_bg
      arrow_fg = inactive_bg
    end

    local ret = tab.is_active
        and {
          { Attribute = { Intensity = "Bold" } },
          { Attribute = { Italic = true } },
        }
      or {}
    ret[#ret + 1] = { Text = title }
    ret[#ret + 1] = { Foreground = { Color = arrow_fg } }
    ret[#ret + 1] = { Background = { Color = arrow_bg } }
    ret[#ret + 1] = { Text = arrow }
    return ret
  end)
end

return M

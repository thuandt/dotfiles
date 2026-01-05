local wezterm = require 'wezterm'
local nerdfonts = wezterm.nerdfonts
local mux = wezterm.mux
local act = wezterm.action
local config = wezterm.config_builder()

-- General configuration --
-- Lauching
-- maximize window on startup
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.default_prog = { os.getenv("SHELL") or "/bin/zsh" }
config.automatically_reload_config = true
config.enable_wayland = true
config.enable_scroll_bar = true

-- Keybindings
config.keys = {
  {
    key = "w",
    mods = "CMD",
    action = wezterm.action.CloseCurrentTab({ confirm = true }),
  },
  -- Map vim-friendly scrolling
  { key = "b", mods = "CTRL", action = act.ScrollByPage(-0.9) },
  { key = "f", mods = "CTRL", action = act.ScrollByPage(0.9) },
}

-- Appearance
config.color_scheme = 'Solarized Dark (Gogh)'
colors = wezterm.get_builtin_color_schemes()[config.color_scheme]
config.font_size = 14.0
config.bold_brightens_ansi_colors = true
config.foreground_text_hsb = {
  brightness = 1.0,
  hue        = 1.0,
  saturation = 1.0,
}
config.text_background_opacity = 0.95
config.window_background_opacity = 0.95
-- Maximize space used by nvim
config.window_padding = {
  left   = 0,
  right  = 0,
  top    = 0,
  bottom = 0,
}
config.font = wezterm.font_with_fallback({
  "CaskaydiaCove Nerd Font",
  "FiraCode Nerd Font",
  "FiraMono Nerd Font",
  "Hack Nerd Font",
  "Fira Code",
})

-- Font for ONLY the tab bar and window frame
config.window_frame = {
  font = wezterm.font({ family = 'CaskaydiaCove Nerd Font Mono', weight = 'Bold' }),
  font_size = 12.0,
}

-- Tab
config.enable_tab_bar = true
config.tab_max_width = 45
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.show_tab_index_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true

-- Events update status
wezterm.on("update-status", function(window, pane)
  -- Workspace name
  local active_key_table = window:active_key_table()
  local stat = window:active_workspace()
  local workspace_color = colors.ansi[3]
  local time = wezterm.strftime("%Y-%m-%d %H:%M")

  if active_key_table then
    stat = active_key_table
    workspace_color = colors.ansi[4]
  elseif window:leader_is_active() then
    stat = "leader"
    workspace_color = colors.ansi[2]
  end

  -- Current working directory
  local cwd = pane:get_current_working_dir()
  if cwd then
    if type(cwd) == "userdata" then
      -- Wezterm introduced the URL object in 20240127-113634-bbcac864
      if string.len(cwd.path) > config.tab_max_width then
        cwd = ".." .. string.sub(cwd.path, config.tab_max_width * -1, -1)
      else
        cwd = cwd.path
      end
    end
  else
    cwd = ""
  end

  -- Left status (left of the tab line)
  window:set_left_status(wezterm.format({
    { Attribute  = { Intensity = "Bold" }                       },
    { Background = { Color = colors.background }                },
    { Text       = " "                                          },
    { Background = { Color = colors.background }                },
    { Foreground = { Color = workspace_color }                  },
    { Text       = nerdfonts.ple_lower_right_triangle           },
    { Background = { Color = workspace_color }                  },
    { Foreground = { Color = colors.ansi[1] }                   },
    { Text       = nerdfonts.cod_terminal_tmux .. " "           },
    { Background = { Color = colors.ansi[1] }                   },
    { Foreground = { Color = workspace_color }                  },
    { Text       = " " .. stat .. " "                           },
    { Background = { Color = colors.background }                },
    { Foreground = { Color = colors.ansi[1] }                   },
    { Text       = nerdfonts.ple_upper_left_triangle .. " "     },
  }))

  -- Right status
  window:set_right_status(wezterm.format({
    { Text       = " "                                   },
    { Background = { Color = colors.background }         },
    { Foreground = { Color = colors.ansi[4] }            },
    { Text       = nerdfonts.ple_lower_right_triangle    },
    { Background = { Color = colors.ansi[4] }            },
    { Foreground = { Color = colors.background }         },
    { Text       = nerdfonts.md_folder .. " "            },
    { Background = { Color = colors.ansi[1] }            },
    { Foreground = { Color = colors.foreground }         },
    { Text       = " " .. cwd                            },
    { Background = { Color = colors.background }         },
    { Foreground = { Color = colors.ansi[1] }            },
    { Text       = nerdfonts.ple_upper_left_triangle     },

    { Text       = " "                                   },
    { Background = { Color = colors.background }         },
    { Foreground = { Color = colors.ansi[8]}             },
    { Text       = nerdfonts.ple_lower_right_triangle    },
    { Background = { Color = colors.ansi[8]}             },
    { Foreground = { Color = colors.background }         },
    { Text       = nerdfonts.md_calendar_clock .. " "    },
    { Background = { Color = colors.ansi[1] }            },
    { Foreground = { Color = colors.foreground }         },
    { Text       = " " .. time                           },
    { Background = { Color = colors.background }         },
    { Foreground = { Color = colors.ansi[1] }            },
    { Text       = nerdfonts.ple_upper_left_triangle     },

  }))

end)


-- https://wezterm.org/config/lua/wezterm/nerdfonts.html
-- https://www.nerdfonts.com/cheat-sheet
local process_icons = {
  ["bash"] = nerdfonts.dev_bash,
  ["zsh"] = nerdfonts.dev_terminal,
  ["fish"] = nerdfonts.seti_fish,
  ["python"] = nerdfonts.dev_python,
  ["uv"] = nerdfonts.dev_python,
  ["poetry"] = nerdfonts.dev_python,
  ["pipenv"] = nerdfonts.dev_python,
  ["ruby"] = nerdfonts.cod_ruby,
  ["cargo"] = nerdfonts.dev_rust,
  ["go"] = nerdfonts.seti_go,
  ["node"] = nerdfonts.dev_nodejs_small,
  ["lua"] = nerdfonts.seti_lua,
  ["claude"] = nerdfonts.md_robot_outline,
  ["vim"] = nerdfonts.dev_vim,
  ["nvim"] = nerdfonts.linux_neovim,
  ["docker"] = nerdfonts.dev_docker,
  ["docker-compose"] = nerdfonts.dev_docker,
  ["gh"] = nerdfonts.dev_github_badge,
  ["git"] = nerdfonts.dev_git,
  ["tig"] = nerdfonts.dev_git_compare,
  ["glab"] = nerdfonts.dev_gitlab,
  ["lazydocker"] = nerdfonts.dev_docker,
  ["lazygit"] = nerdfonts.dev_git_branch,
  ["make"] = nerdfonts.seti_makefile,
  ["mise"] = nerdfonts.md_carrot,
  ["psql"] = nerdfonts.dev_postgresql,
  ["pgcli"] = nerdfonts.dev_postgresql,
  ["mysql"] = nerdfonts.dev_mysql,
  ["mycli"] = nerdfonts.dev_mysql,
  ["usql"] = nerdfonts.dev_database,
  ["terraform"] = nerdfonts.md_terraform,
  ["aws"] = nerdfonts.dev_aws,
  ["az"] = nerdfonts.dev_azure,
  ["gcloud"] = nerdfonts.dev_google_cloud,
  ["kubectl"] = nerdfonts.md_kubernetes,
  ["k9s"] = nerdfonts.md_kubernetes,
  ["helm"] = nerdfonts.dev_helm,
  ["sudo"] = nerdfonts.fa_hashtag,
  ["btm"] = nerdfonts.md_monitor_eye,
  ["htop"] = nerdfonts.md_monitor_eye,
  ["curl"] = nerdfonts.md_arrow_down_box,
  ["wget"] = nerdfonts.md_arrow_down_box,
  ["ssh"] = nerdfonts.md_remote_desktop,
  ["watch"] = nerdfonts.md_eye_outline
}

local icon_active = nerdfonts.md_rocket_launch
local icon_unseen = nerdfonts.cod_eye_closed
local icon_git_root = "./"
local icon_not_git = nerdfonts.md_map_marker_radius

-- Non-breaking space to prevent Wezterm from collapsing consecutive spaces
local nbsp = "\u{00A0}"

-- Git lookup cache to avoid repeated expensive io.popen calls
local git_cache = {}
local GIT_CACHE_TTL = 600 -- 10 minutes

local function get_cached_git_root(cwd)
  local now = os.time()
  local cached = git_cache[cwd]

  if cached and (now - cached.timestamp) < GIT_CACHE_TTL then
    return cached.root, cached.is_git_repo, cached.depth_indicator
  end

  local git_root = ""
  local is_git_repo = false
  local depth_indicator = icon_not_git

  local handle = io.popen("cd '" .. cwd .. "' 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null")
  if handle then
    git_root = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    if git_root ~= "" then
      is_git_repo = true

      -- At git root
      if cwd == git_root then
        depth_indicator = icon_git_root
      else
        -- Calculate depth indicator while we have the git root
        local relative_path = cwd:gsub("^" .. git_root:gsub("([^%w])", "%%%1") .. "/?", "")
        local depth = 0
        for _ in relative_path:gmatch("/") do
            depth = depth + 1
        end
        depth = depth + 1

        local current_dir = cwd:match("([^/]+)$") or ""
        local prefix = current_dir:sub(1, 2):lower()
        depth_indicator = string.format("%d%s", depth, prefix)
      end
    end
  end

  git_cache[cwd] = {
    root = git_root,
    is_git_repo = is_git_repo,
    depth_indicator = depth_indicator,
    timestamp = now,
  }

  for key, value in pairs(git_cache) do
    if (now - value.timestamp) >= GIT_CACHE_TTL * 2 then git_cache[key] = nil end
  end

  return git_root, is_git_repo, depth_indicator
end

-- Return the Tab's current working directory
local function get_cwd(tab)
  -- Note, returns URL Object: https://wezterm.org/config/lua/pane/get_current_working_dir.html
  return tab.active_pane.current_working_dir.file_path or ""
end

-- Remove all path components and return only the last value
local function remove_abs_path(path) return path:gsub("(.*[/\\])(.*)", "%2") end

-- Calculate depth from git root and create indicator (uses cached value)
local function get_git_depth_indicator(tab)
  local cwd = get_cwd(tab):gsub("^file://", "")
  local _, _, depth_indicator = get_cached_git_root(cwd)
  return depth_indicator
end

-- Get the git root directory name, or fallback to current directory name
local function get_git_dir_name(tab)
  local cwd = get_cwd(tab):gsub("^file://", "")
  local git_root, is_git_repo, _ = get_cached_git_root(cwd)
  if is_git_repo then return remove_abs_path(git_root) end
  return "./" .. remove_abs_path(cwd)
end

-- Return the concise name or icon of the running process for display
local function get_process(tab)
  if not tab.active_pane or tab.active_pane.foreground_process_name == "" then return "[?]" end
  local process_name = remove_abs_path(tab.active_pane.foreground_process_name)
  return process_icons[process_name] or string.format("[%s]", process_name)
end

-- Format the main content of the tab (everything except edge whitespace)
local function format_tab_content(tab, has_unseen)
  local dir_name = get_git_dir_name(tab)
  local depth_indicator = get_git_depth_indicator(tab)
  local process = get_process(tab)

  -- Pad directory name to be at least 10 characters with whitespace on both sides
  local min_width = 10
  local dir_len = #dir_name
  if dir_len < min_width then
    local padding = min_width - dir_len
    local left_pad = math.floor(padding / 2)
    local right_pad = padding - left_pad
    dir_name = string.rep(" ", left_pad) .. dir_name .. string.rep(" ", right_pad)
  end

  local unseen_indicator = has_unseen and icon_unseen or " "
  return string.format("%s %s %s %s ", unseen_indicator, process, dir_name, depth_indicator)
end

-- Helper to add a segment to the format table
local function add_segment(format, bg_color, fg_color, text, bold)
  table.insert(format, { Background = { Color = bg_color } })
  table.insert(format, { Foreground = { Color = fg_color } })
  if bold then table.insert(format, { Attribute = { Intensity = "Bold" } }) end
  table.insert(format, { Text = text })
end

-- Track which tabs have been visited to work around buggy has_unseen_output
local visited_tabs = {}

-- Determine if a tab has unseen output since last visited
local function has_unseen_output(tab)
  local tab_id = tab.tab_id

  -- If tab is currently active, mark it as visited
  if tab.is_active then
    visited_tabs[tab_id] = true
    return false
  end

  -- For inactive tabs, check if we've visited them before
  if visited_tabs[tab_id] then
    return false -- Already visited, no indicator
  end

  -- Not visited yet, check if there's unseen output
  for _, pane in ipairs(tab.panes) do
    if pane.has_unseen_output then return true end
  end

  return false
end

-- Convert arbitrary strings to a unique hex color value
-- Based on: https://stackoverflow.com/a/3426956/3219667
local function string_to_color(str)
  -- Convert the string to a unique integer
  local hash = 0
  for i = 1, #str do
    -- Bitwise Left Shift: (hash << 5) is equivalent to hash * 32
    hash = string.byte(str, i) + (hash * 32 - hash)
  end
  -- Convert the integer to a unique color (mask to 24 bits)
  -- Bitwise AND with 0x00FFFFFF is equivalent to modulo 0x01000000
  local c = string.format("%06X", math.abs(hash) % 0x01000000)
  return "#" .. (string.rep("0", 6 - #c) .. c):upper()
end

local function select_contrasting_fg_color(hex_color)
  local color = wezterm.color.parse(hex_color)
  ---@diagnostic disable-next-line: unused-local
  local lightness, _a, _b, _alpha = color:laba()
  if lightness > 55 then
    return "#000000" -- Black has higher contrast with colors perceived to be "bright"
  end
  return "#FFFFFF" -- White has higher contrast
end

-- Get full git root path for color hashing (not just the name)
local function get_git_root_path(tab)
  local cwd = get_cwd(tab):gsub("^file://", "")
  local git_root, is_git_repo, _ = get_cached_git_root(cwd)
  if is_git_repo then return git_root end
  return cwd
end

-- Helper function to dim colors for inactive tabs
local function dim_color(hex_color, factor)
  local color = wezterm.color.parse(hex_color)
  local h, s, l, a = color:hsla()
  -- Reduce lightness for inactive tabs to make them more subtle
  l = l * factor
  local dimmed = wezterm.color.from_hsla(h, s, l, a)
  -- Convert back to hex string format
  local r, g, b, _ = dimmed:srgba_u8()
  return string.format("#%02X%02X%02X", r, g, b)
end

-- On format tab title events, override the default handling to return a custom title
-- Docs: https://wezterm.org/config/lua/window-events/format-tab-title.html
---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, _max_width)
  local has_unseen = has_unseen_output(tab)
  local base_color = string_to_color(get_git_root_path(tab))

  -- Handle custom titles
  if tab.tab_title and #tab.tab_title > 0 then
    local bg_color = tab.is_active and colors.ansi[6] or dim_color(base_color, 0.7)
    local fg_color = select_contrasting_fg_color(bg_color)
    local format = {}
    local padding = tab.is_active and (nbsp .. nbsp) or nbsp
    add_segment(format, bg_color, fg_color, padding .. tab.tab_title .. padding, true)
    return format
  end

  local content = format_tab_content(tab, has_unseen)
  local format = {}

  if tab.is_active then
    -- Active tab: left edge with rocket, padded colored content
    local off_white = colors.ansi[6]
    local main_bg = base_color
    local main_fg = select_contrasting_fg_color(main_bg)

    add_segment(format, off_white, "#000000", " " .. icon_active .. " ", true)
    add_segment(format, main_bg, main_fg, " " .. content .. " ", true)
    add_segment(format, off_white, "#000000", " " .. icon_active .. " ", true)
  else
    -- Inactive tab: single color with minimal padding (narrower)
    local bg_color = dim_color(base_color, 0.7)
    local fg_color = select_contrasting_fg_color(bg_color)
    add_segment(format, bg_color, fg_color, content, true)
  end

  return format
end)

return config

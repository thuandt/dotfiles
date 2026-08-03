local wezterm = require 'wezterm'
local nerdfonts = wezterm.nerdfonts
local mux = wezterm.mux
local act = wezterm.action
local config = wezterm.config_builder()

--------------------------------------------------------------------------------
-- 1. General & Startup Configuration
--------------------------------------------------------------------------------

-- Maximize window on startup
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.default_prog = { os.getenv("SHELL") or "/bin/zsh" }
config.automatically_reload_config = true
config.enable_wayland = true
config.prefer_egl = true
config.enable_scroll_bar = true
config.status_update_interval = 1000

--------------------------------------------------------------------------------
-- 2. Appearance & Typography
--------------------------------------------------------------------------------

-- Appearance Reference Palette
-- https://github.com/Gogh-Co/Gogh/blob/master/themes/Selenized%20Dark.yml
-- https://github.com/jan-warchol/selenized
-- name: 'Selenized Dark'
-- author: ''             # 'AUTHOR NAME (http://WEBSITE.com)'
-- variant: 'dark'            # dark or light

-- color_01: '#184956'    # Black (Host)                -> colors.ansi[1]
-- color_02: '#fa5750'    # Red (Syntax string)         -> colors.ansi[2]
-- color_03: '#75b938'    # Green (Command)             -> colors.ansi[3]
-- color_04: '#dbb32d'    # Yellow (Command second)     -> colors.ansi[4]
-- color_05: '#4695f7'    # Blue (Path)                 -> colors.ansi[5]
-- color_06: '#f275be'    # Magenta (Syntax var)        -> colors.ansi[6]
-- color_07: '#41c7b9'    # Cyan (Prompt)               -> colors.ansi[7]
-- color_08: '#72898f'    # White                       -> colors.ansi[8]

-- color_09: '#2d5b69'    # Bright Black                -> colors.brights[1]
-- color_10: '#ff665c'    # Bright Red (Command error)  -> colors.brights[2]
-- color_11: '#84c747'    # Bright Green (Exec)         -> colors.brights[3]
-- color_12: '#ebc13d'    # Bright Yellow               -> colors.brights[4]
-- color_13: '#58a3ff'    # Bright Blue (Folder)        -> colors.brights[5]
-- color_14: '#ff84cd'    # Bright Magenta              -> colors.brights[6]
-- color_15: '#53d6c7'    # Bright Cyan                 -> colors.brights[7]
-- color_16: '#cad8d9'    # Bright White                -> colors.brights[8]

-- background: '#103c48'  # Background                  -> colors.background
-- foreground: '#adbcbc'  # Foreground (Text)           -> colors.foreground

-- cursor: '#cad8d9'      # Cursor                      -> colors.cursor_bg

config.color_scheme = 'Selenized Dark (Gogh)'
local colors = wezterm.get_builtin_color_schemes()[config.color_scheme] or {}

config.colors = {
  tab_bar = {
    background = colors.background or '#103c48',
  },
}

config.font_size = 14.0
config.bold_brightens_ansi_colors = "BrightAndBold"
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
  {
    family = 'CaskaydiaCove Nerd Font',
    weight = 'Medium',
  },
  {
    family = 'FiraCode Nerd Font',
    weight = 'Medium',
  },
})

-- Font for ONLY the tab bar and window frame
config.window_frame = {
  font = wezterm.font({ family = 'CaskaydiaCove Nerd Font' }),
  font_size = 12.0,
}

-- Tab Bar Layout
config.enable_tab_bar = true
config.tab_max_width = 45
config.use_fancy_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true

--------------------------------------------------------------------------------
-- 3. Keybindings
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- 4. Process Icons & Constants
--------------------------------------------------------------------------------

-- https://wezterm.org/config/lua/wezterm/nerdfonts.html
-- https://www.nerdfonts.com/cheat-sheet
local process_icons = {
  -- Shells
  ["bash"]           = nerdfonts.dev_bash,
  ["zsh"]            = nerdfonts.dev_terminal,
  ["fish"]           = nerdfonts.seti_fish,

  -- Languages & Runtimes
  ["ruby"]           = nerdfonts.cod_ruby,
  ["cargo"]          = nerdfonts.dev_rust,
  ["go"]             = nerdfonts.seti_go,
  ["lua"]            = nerdfonts.seti_lua,

  -- Editors & AI
  ["nvim"]           = nerdfonts.linux_neovim,
  ["claude"]         = nerdfonts.md_robot_outline,

  -- Git & Cloud Platform Specific Icons
  ["gh"]             = nerdfonts.dev_github_badge,
  ["glab"]           = nerdfonts.dev_gitlab,
  ["tig"]            = nerdfonts.dev_git_compare,
  ["lazygit"]        = nerdfonts.dev_git_branch,
  ["aws"]            = nerdfonts.dev_aws,
  ["az"]             = nerdfonts.dev_azure,
  ["gcloud"]         = nerdfonts.dev_google_cloud,
  ["helm"]           = nerdfonts.dev_helm,
  ["terraform"]      = nerdfonts.md_terraform,

  -- Databases & Tools
  ["usql"]           = nerdfonts.dev_database,
  ["make"]           = nerdfonts.seti_makefile,
  ["mise"]           = nerdfonts.md_carrot,
  ["sudo"]           = nerdfonts.fa_hashtag,
  ["curl"]           = nerdfonts.md_arrow_down_box,
  ["wget"]           = nerdfonts.md_arrow_down_box,
  ["ssh"]            = nerdfonts.md_remote_desktop,
  ["watch"]          = nerdfonts.md_eye_outline,
}

-- Fallback pattern rules (Lua regex / pattern matching)
local process_patterns = {
  -- Process Monitors (*top, btm)
  { pattern = "top$",        icon = nerdfonts.md_monitor_eye },     -- htop, btop, atop, abtop, ytop, gtop, nvtop
  { pattern = "^btm$",       icon = nerdfonts.md_monitor_eye },     -- bottom (btm)

  -- Git Tools (*git, git-*)
  { pattern = "git",         icon = nerdfonts.dev_git },             -- git, lazygit, git-lfs, git-town, etc.

  -- Docker & Containers
  { pattern = "docker",      icon = nerdfonts.dev_docker },          -- docker, docker-compose, lazydocker
  { pattern = "podman",      icon = nerdfonts.dev_docker },          -- podman

  -- Kubernetes Tools (kube*, k9s, k8s, k3s)
  { pattern = "kube",        icon = nerdfonts.md_kubernetes },       -- kubectl, kubectx, kubens
  { pattern = "^k[389]s$",   icon = nerdfonts.md_kubernetes },       -- k9s, k8s, k3s

  -- Python Runtimes & Tools
  { pattern = "python",      icon = nerdfonts.dev_python },          -- python, python3, ipython, bpython
  { pattern = "^py",         icon = nerdfonts.dev_python },          -- pytest, poetry, etc.

  -- Editors (vim, nvim, neovim, gvim)
  { pattern = "vim$",        icon = nerdfonts.dev_vim },             -- vim, nvim, gvim, neovim

  -- Databases (postgres / mysql)
  { pattern = "^pg",         icon = nerdfonts.dev_postgresql },      -- psql, pgcli, pg_dump
  { pattern = "psql",        icon = nerdfonts.dev_postgresql },      -- psql
  { pattern = "^my",         icon = nerdfonts.dev_mysql },           -- mysql, mycli

  -- Node / JS / TS Runtimes & Package Managers
  { pattern = "^node",       icon = nerdfonts.dev_nodejs_small },    -- node, nodejs
  { pattern = "^npm",        icon = nerdfonts.dev_nodejs_small },    -- npm, npx
  { pattern = "^pnpm",       icon = nerdfonts.dev_nodejs_small },    -- pnpm
  { pattern = "^yarn",       icon = nerdfonts.dev_nodejs_small },    -- yarn
  { pattern = "^bun",        icon = nerdfonts.dev_nodejs_small },    -- bun
  { pattern = "^deno",       icon = nerdfonts.dev_nodejs_small },    -- deno
}

local icon_active = nerdfonts.md_rocket_launch
local icon_unseen = nerdfonts.cod_eye_closed
local icon_git_root = "./"
local icon_not_git = nerdfonts.md_map_marker_radius

-- Non-breaking space to prevent Wezterm from collapsing consecutive spaces
local nbsp = "\u{00A0}"

--------------------------------------------------------------------------------
-- 5. Git & Path Helpers (with TTL Caching)
--------------------------------------------------------------------------------

-- Git lookup cache to avoid repeated expensive io.popen calls
local git_cache = {}
local GIT_CACHE_TTL = 600 -- 10 minutes

local function get_cached_git_root(cwd)
  if not cwd or cwd == "" then
    return "", false, icon_not_git
  end

  local now = os.time()
  local cached = git_cache[cwd]

  if cached and (now - cached.timestamp) < GIT_CACHE_TTL then
    return cached.root, cached.is_git_repo, cached.depth_indicator
  end

  local git_root = ""
  local is_git_repo = false
  local depth_indicator = icon_not_git

  local safe_cwd = cwd:gsub("'", "'\\''")
  local handle = io.popen("cd '" .. safe_cwd .. "' 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null")
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
    if (now - value.timestamp) >= GIT_CACHE_TTL * 2 then
      git_cache[key] = nil
    end
  end

  return git_root, is_git_repo, depth_indicator
end

-- Return the Tab's current working directory
local function get_cwd(tab)
  -- Note, returns URL Object: https://wezterm.org/config/lua/pane/get_current_working_dir.html
  if tab.active_pane and tab.active_pane.current_working_dir then
    return tab.active_pane.current_working_dir.file_path
  else
    return ""
  end
end

-- Remove all path components and return only the last value
local function remove_abs_path(path)
  return path:gsub("(.*[/\\])(.*)", "%2")
end

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
  if is_git_repo then
    return remove_abs_path(git_root)
  end
  return "./" .. remove_abs_path(cwd)
end

-- Return the concise name or icon of the running process for display
local function get_process(tab)
  if not tab.active_pane or not tab.active_pane.foreground_process_name or tab.active_pane.foreground_process_name == "" then
    return "[?]"
  end
  local process_name = remove_abs_path(tab.active_pane.foreground_process_name)
  -- Strip trailing version suffixes (e.g., python3.12) to match icon keys
  local normalized_name = process_name:gsub("[%d%.]+$", "")
  if normalized_name == "" then
    normalized_name = process_name
  end

  local icon = process_icons[process_name] or process_icons[normalized_name]
  if not icon then
    for _, item in ipairs(process_patterns) do
      if normalized_name:find(item.pattern) then
        icon = item.icon
        break
      end
    end
  end

  return icon or string.format("[%s]", process_name)
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
  if bold then
    table.insert(format, { Attribute = { Intensity = "Bold" } })
  end
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
    if pane.has_unseen_output then
      return true
    end
  end

  return false
end

--------------------------------------------------------------------------------
-- 6. Color Hashing & Dimming Utilities (Memoized)
--------------------------------------------------------------------------------

-- Memoization cache for string color hashing and color dimming
local color_hash_cache = {}
local dim_cache = {}

-- Convert arbitrary strings to a unique hex color value
-- Based on: https://stackoverflow.com/a/3426956/3219667
local function string_to_color(str)
  if color_hash_cache[str] then
    return color_hash_cache[str]
  end
  -- Convert the string to a unique integer
  local hash = 0
  for i = 1, #str do
    -- Bitwise Left Shift: (hash << 5) is equivalent to hash * 32
    hash = string.byte(str, i) + (hash * 32 - hash)
  end
  -- Convert the integer to a unique color (mask to 24 bits)
  -- Bitwise AND with 0x00FFFFFF is equivalent to modulo 0x01000000
  local c = string.format("%06X", math.abs(hash) % 0x01000000)
  local res = "#" .. (string.rep("0", 6 - #c) .. c):upper()
  color_hash_cache[str] = res
  return res
end

local function select_contrasting_fg_color(hex_color)
  local color = wezterm.color.parse(hex_color)
  ---@diagnostic disable-next-line: unused-local
  local lightness, _a, _b, _alpha = color:laba()
  if lightness > 55 then
    return "#000000" -- Black has higher contrast with colors perceived to be "bright"
  end
  return "#FFFFFF"   -- White has higher contrast
end

-- Get full git root path for color hashing (not just the name)
local function get_git_root_path(tab)
  local cwd = get_cwd(tab):gsub("^file://", "")
  local git_root, is_git_repo, _ = get_cached_git_root(cwd)
  if is_git_repo then
    return git_root
  end
  return cwd
end

-- Helper function to dim colors for inactive tabs
local function dim_color(hex_color, factor)
  local cache_key = hex_color .. ":" .. tostring(factor)
  if dim_cache[cache_key] then
    return dim_cache[cache_key]
  end
  local color = wezterm.color.parse(hex_color)
  local h, s, l, a = color:hsla()
  -- Reduce lightness for inactive tabs to make them more subtle
  l = l * factor
  local dimmed = wezterm.color.from_hsla(h, s, l, a)
  -- Convert back to hex string format
  local r, g, b, _ = dimmed:srgba_u8()
  local res = string.format("#%02X%02X%02X", r, g, b)
  dim_cache[cache_key] = res
  return res
end

--------------------------------------------------------------------------------
-- 7. Status Bar & Tab Title Formatting Events
--------------------------------------------------------------------------------

-- Events update status
wezterm.on("update-status", function(window, pane)
  -- Fallback palette (Selenized Dark)
  local bg_main          = colors.background or "#103c48"
  local fg_main          = colors.foreground or "#adbcbc"
  local ansi_1           = colors.ansi and colors.ansi[1] or "#184956"
  local ansi_7           = colors.ansi and colors.ansi[7] or "#41c7b9"

  -- Workspace name
  local active_key_table = window:active_key_table()
  local stat             = window:active_workspace()
  local workspace_color  = ansi_7
  local time             = wezterm.strftime("%Y-%m-%d %H:%M")

  if active_key_table then
    stat = active_key_table
    workspace_color = colors.ansi and colors.ansi[2] or "#fa5750"
  elseif window:leader_is_active() then
    stat = "leader"
    workspace_color = colors.ansi and colors.ansi[4] or "#db9d26"
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

  ---@format disable
  -- Left status (left of the tab line)
  window:set_left_status(wezterm.format({
    { Attribute  = { Intensity = "Bold" }               },
    { Background = { Color = bg_main }                  },
    { Text       = " "                                  },
    { Background = { Color = bg_main }                  },
    { Foreground = { Color = workspace_color }          },
    { Text       = nerdfonts.ple_lower_right_triangle   },
    { Background = { Color = workspace_color }          },
    { Foreground = { Color = ansi_1 }                   },
    { Text       = nerdfonts.cod_terminal_tmux .. " "   },
    { Background = { Color = ansi_1 }                   },
    { Foreground = { Color = workspace_color }          },
    { Text       = " " .. stat .. " "                   },
    { Background = { Color = bg_main }                  },
    { Foreground = { Color = ansi_1 }                   },
    { Text       = nerdfonts.ple_upper_left_triangle    },
  }))

  -- Right status
  window:set_right_status(wezterm.format({
    { Text       = " "                                  },
    { Background = { Color = bg_main }                  },
    { Foreground = { Color = ansi_7 }                   },
    { Text       = nerdfonts.ple_lower_right_triangle   },
    { Background = { Color = ansi_7 }                   },
    { Foreground = { Color = bg_main }                  },
    { Text       = nerdfonts.md_folder .. " "           },
    { Background = { Color = ansi_1 }                   },
    { Foreground = { Color = fg_main }                  },
    { Text       = " " .. cwd                           },
    { Background = { Color = bg_main }                  },
    { Foreground = { Color = ansi_1 }                   },
    { Text       = nerdfonts.ple_upper_left_triangle    },

    { Text       = " "                                  },
    { Background = { Color = bg_main }                  },
    { Foreground = { Color = ansi_7 }                   },
    { Text       = nerdfonts.ple_lower_right_triangle   },
    { Background = { Color = ansi_7 }                   },
    { Foreground = { Color = bg_main }                  },
    { Text       = nerdfonts.md_calendar_clock .. " "   },
    { Background = { Color = ansi_1 }                   },
    { Foreground = { Color = fg_main }                  },
    { Text       = " " .. time                          },
    { Background = { Color = bg_main }                  },
    { Foreground = { Color = ansi_1 }                   },
    { Text       = nerdfonts.ple_upper_left_triangle    },
  }))
  ---@format enabled
end)

-- On format tab title events, override the default handling to return a custom title
-- Docs: https://wezterm.org/config/lua/window-events/format-tab-title.html
---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, _max_width)
  local has_unseen = has_unseen_output(tab)
  local base_color = string_to_color(get_git_root_path(tab))
  local off_white = (colors.brights and colors.brights[8]) or "#cad8d9"

  -- Handle custom titles
  if tab.tab_title and #tab.tab_title > 0 then
    local bg_color = tab.is_active and off_white or dim_color(base_color, 0.7)
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

--------------------------------------------------------------------------------
-- 8. Custom Hyperlink Rules & Editor Open Handler
--------------------------------------------------------------------------------

-- Helper to resolve relative file paths against pane CWD
local function resolve_file_path(pane, file_path)
  -- 1. Direct absolute path check
  local f = io.open(file_path, "r")
  if f then
    f:close()
    return file_path
  end

  -- 2. Strip leading slash added by file:/// format
  local rel_path = file_path:gsub("^/", "")
  f = io.open(rel_path, "r")
  if f then
    f:close()
    return rel_path
  end

  -- 3. Resolve relative to pane current working directory
  if pane and pane.get_current_working_dir then
    local cwd_url = pane:get_current_working_dir()
    if cwd_url and cwd_url.file_path then
      local cwd = cwd_url.file_path
      local abs_path = cwd .. "/" .. rel_path
      f = io.open(abs_path, "r")
      if f then
        f:close()
        return abs_path
      end
    end
  end

  return file_path
end

-- Open file hyperlinks in Neovim / VSCode / $EDITOR at line number
wezterm.on("open-uri", function(window, pane, uri)
  if uri:find("^file://") then
    -- Strip file:// prefix and decode URL spaces (%20)
    local clean_path = uri:gsub("^file://", ""):gsub("%%20", " ")
    local raw_path, line = clean_path:match("^([^:#]+)[:#]?L?(%d*)")

    if raw_path and raw_path ~= "" then
      local file_path = resolve_file_path(pane, raw_path)
      local editor = os.getenv("VISUAL") or os.getenv("EDITOR") or "nvim"
      line = (line and line ~= "") and line or "1"

      if editor:find("code") then
        -- VS Code: code -g file:line
        local safe_path = file_path:gsub("'", "'\\''")
        io.popen(string.format("code -g '%s:%s'", safe_path, line))
        return false
      else
        -- Neovim / Vim: Open in new tab in WezTerm
        window:perform_action(
          act.SpawnCommandInNewTab({
            args = { editor, "+" .. line, file_path },
          }),
          pane
        )
        return false
      end
    end
  end
end)

-- Explicit mouse binding for CTRL+Click to open links
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
}

-- Hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Match file paths with line numbers (e.g. main.py:42, src/lib.rs:10:5, or path/to/file.lua:100)
table.insert(config.hyperlink_rules, {
  regex = [[\b([a-zA-Z0-9_.~/-]+\.[a-zA-Z0-9]+):(\d+)(?::(\d+))?\b]],
  format = "file:///$1:$2",
})

local issue_trackers = {
  { prefixes = { 'US', 'DE', 'E', 'F' }, url = 'https://rally1.rallydev.com/#/search?keywords=$1' },
}

-- Load private issue trackers if available
local has_private, private_trackers = pcall(require, 'private_issue_trackers')
if has_private and type(private_trackers) == 'table' then
  for _, entry in ipairs(private_trackers) do
    table.insert(issue_trackers, entry)
  end
end

for _, entry in ipairs(issue_trackers) do
  local pattern = table.concat(entry.prefixes, '|')
  table.insert(config.hyperlink_rules, {
    regex = string.format([[\b((?:%s)\d+)\b]], pattern),
    format = entry.url,
  })
end

return config

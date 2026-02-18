{
  osConfig,
  lib,
  fontFamily,
  ...
}: {
  config = lib.mkIf (osConfig.aspects.terminal.whichOne == "wezterm") {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require("wezterm")
        local mux = wezterm.mux
        local tab_pos = "bottom"
        local config = wezterm.config_builder()
        -- local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
        local tabbar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")

        local mods = {
        	C = "CTRL",
        	M = "ALT",
        	S = "SHIFT",
        	L = "LEADER",
        }

        local join_mods = function(m)
        	local result = ""
        	for i, v in ipairs(m) do
        		result = result .. v
        		if i < #m then
        			result = result .. "|"
        		end
        	end
        	return result
        end

        config.font = wezterm.font("${fontFamily}")
        config.adjust_window_size_when_changing_font_size = false
        config.font_size = ${toString osConfig.aspects.terminal.fontSize}
        config.freetype_load_target = "Light"
        config.line_height = 1
        config.window_background_opacity = ${toString osConfig.aspects.terminal.opacity}
        config.default_cursor_style = "BlinkingBlock"
        config.cursor_blink_rate = 500
        config.tab_bar_at_bottom = false

        -- Gruvbox Theme
        config.color_scheme = "Gruvbox dark, hard (base16)"

        config.enable_scroll_bar = false
        config.window_decorations = "NONE"
        config.window_padding = {
        	bottom = ${toString osConfig.aspects.terminal.padding},
        	right = ${toString osConfig.aspects.terminal.padding},
        	left = ${toString osConfig.aspects.terminal.padding},
        	top = ${toString osConfig.aspects.terminal.padding},
        }

        -- Leader Key: Alt+Q
        config.leader = {
        	key = "q",
        	mods = mods.M,
        	timeout_milliseconds = 1500,
        }

        config.keys = {
        	-- Create new tab
        	{ key = "n", mods = mods.L, action = wezterm.action.SpawnTab("DefaultDomain"), },
        	-- Rename tab
        	{
        		key = "e",
        		mods = mods.L,
        		action = wezterm.action.PromptInputLine({
        			description = "Rename tab",
        			action = wezterm.action_callback(function(window, _, line)
        				if line then
        					window:active_tab():set_title(line)
        				end
        			end),
        		}),
        	},
        	-- Duplicate tab
        	{ key = "d", mods = mods.L, action = wezterm.action.SpawnTab("CurrentPaneDomain"), },
        	-- Close pane
        	{ key = "c", mods = mods.L, action = wezterm.action.CloseCurrentPane({ confirm = true }), },
        	-- Close tab
        	{ key = "x", mods = mods.L, action = wezterm.action.CloseCurrentTab({ confirm = true }), },
        	-- Workspace
        	{
        		key = "w",
        		mods = mods.L,
        		action = wezterm.action.PromptInputLine({
        			description = "Enter name for workspace",
        			action = wezterm.action_callback(function(window, pane, line)
        				if line then
        					window:perform_action(
        						wezterm.action.SwitchToWorkspace({
        							name = line,
        						}),
        						pane
        					)
        				end
        			end),
        		}),
        	},
        	-- Focus zoom
        	{ key = "f", mods = mods.L, action = wezterm.action.TogglePaneZoomState, },
        	-- Launcher
        	{ key = "\\", mods = mods.L, action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES", }), },
        	-- Workspaces cycle
        	{ key = "]", mods = mods.L, action = wezterm.action.SwitchWorkspaceRelative(1), },
        	{ key = "[", mods = mods.L, action = wezterm.action.SwitchWorkspaceRelative(-1), },
        	{ key = "o", mods = mods.L, action = "ShowLauncher", },

        	-- Split pane right (L)
        	{
        		key = "L",
        		mods = mods.L,
        		action = wezterm.action.SplitHorizontal({
        			domain = "CurrentPaneDomain",
        		}),
        	},
        	-- Split pane down (J)
        	{
        		key = "J",
        		mods = mods.L,
        		action = wezterm.action.SplitVertical({
        			domain = "CurrentPaneDomain",
        		}),
        	},

        	-- Tab relative
        	{ key = "l", mods = join_mods({ mods.M, mods.S }), action = wezterm.action.ActivateTabRelative(1), },
        	{ key = "h", mods = join_mods({ mods.M, mods.S }), action = wezterm.action.ActivateTabRelative(-1), },

        	-- Pane navigation (hjkl)
        	{ key = "h", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Left"), },
        	{ key = "l", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Right"), },
        	{ key = "k", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Up"), },
        	{ key = "j", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Down"), },

        	-- Clipboard
        	{ key = "c", mods = join_mods({ mods.C, mods.S }), action = wezterm.action.CopyTo("Clipboard"), },
        	{ key = "v", mods = join_mods({ mods.C, mods.S }), action = wezterm.action.PasteFrom("Clipboard"), },

        	-- Selection
        	{ key = "p", mods = mods.L, action = wezterm.action.PaneSelect({ alphabet = "123456", }), },
        	{ key = "p", mods = join_mods({ mods.L, mods.S }), action = wezterm.action.PaneSelect({ alphabet = "123456", mode = "SwapWithActive", }), },
        }

         -- Maximize window on startup
         wezterm.on("gui-startup", function(cmd)
           local _, _, window = mux.spawn_window(cmd or {})
           window:gui_window():maximize()
         end)

          --tabline.setup({
          --	options = {
          --		theme = config.color_scheme,
          --	},
          --	sections = {
          --		tabline_a = {
          --			"hostname",
          --		},
          --		tab_active = {
          --			"index",
          --			{ "process", padding = { right = 1, left = 0 } },
          --		},
          --	},
          --})

          --tabline.apply_to_config(config)

         tabbar.apply_to_config(config, {
         	position = tab_pos,
         	modules = {
         		clock = { enabled = false },
         		zoom = { enabled = true },
         		cwd = { enabled = false },
         	},
         })

         return config
      '';
    };
  };
}

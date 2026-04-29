{
  den.aspects.my._.terminals._.wezterm = terminal: {
    homeManager = {
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local wezterm = require("wezterm")
          local mux = wezterm.mux
          local tab_pos = "bottom"
          local config = wezterm.config_builder()
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

          config.font_size = ${toString terminal.fontSize}
          config.adjust_window_size_when_changing_font_size = false
          config.freetype_load_target = "Light"
          config.line_height = 1
          config.window_background_opacity = 1
          config.default_cursor_style = "BlinkingBlock"
          config.cursor_blink_rate = 500
          config.tab_bar_at_bottom = false

          config.enable_scroll_bar = false
          config.window_decorations = "NONE"
          config.window_padding = {
            bottom = ${toString terminal.padding},
            right = ${toString terminal.padding},
            left = ${toString terminal.padding},
            top = ${toString terminal.padding},
          }

          config.leader = {
            key = "q",
            mods = mods.M,
            timeout_milliseconds = 1500,
          }

          config.keys = {
            { key = "n", mods = mods.L, action = wezterm.action.SpawnTab("DefaultDomain"), },
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
            { key = "d", mods = mods.L, action = wezterm.action.SpawnTab("CurrentPaneDomain"), },
            { key = "c", mods = mods.L, action = wezterm.action.CloseCurrentPane({ confirm = true }), },
            { key = "x", mods = mods.L, action = wezterm.action.CloseCurrentTab({ confirm = true }), },
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
            { key = "f", mods = mods.L, action = wezterm.action.TogglePaneZoomState, },
            { key = "\\", mods = mods.L, action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES", }), },
            { key = "]", mods = mods.L, action = wezterm.action.SwitchWorkspaceRelative(1), },
            { key = "[", mods = mods.L, action = wezterm.action.SwitchWorkspaceRelative(-1), },
            { key = "o", mods = mods.L, action = "ShowLauncher", },

            {
              key = "L",
              mods = mods.L,
              action = wezterm.action.SplitHorizontal({
                domain = "CurrentPaneDomain",
              }),
            },
            {
              key = "J",
              mods = mods.L,
              action = wezterm.action.SplitVertical({
                domain = "CurrentPaneDomain",
              }),
            },

            { key = "l", mods = join_mods({ mods.M, mods.S }), action = wezterm.action.ActivateTabRelative(1), },
            { key = "h", mods = join_mods({ mods.M, mods.S }), action = wezterm.action.ActivateTabRelative(-1), },

            { key = "h", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Left"), },
            { key = "l", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Right"), },
            { key = "k", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Up"), },
            { key = "j", mods = mods.L, action = wezterm.action.ActivatePaneDirection("Down"), },

            { key = "c", mods = join_mods({ mods.C, mods.S }), action = wezterm.action.CopyTo("Clipboard"), },
            { key = "v", mods = join_mods({ mods.C, mods.S }), action = wezterm.action.PasteFrom("Clipboard"), },

            { key = "p", mods = mods.L, action = wezterm.action.PaneSelect({ alphabet = "123456", }), },
            { key = "p", mods = join_mods({ mods.L, mods.S }), action = wezterm.action.PaneSelect({ alphabet = "123456", mode = "SwapWithActive", }), },
          }

          wezterm.on("gui-startup", function(cmd)
            local _, _, window = mux.spawn_window(cmd or {})
            window:gui_window():maximize()
          end)

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
  };
}

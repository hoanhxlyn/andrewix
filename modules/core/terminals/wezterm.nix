{lib, ...}: {
  core.terminals.wezterm = {host, ...}: let
    inherit (host) terminal;
    mods = {
      C = "CTRL";
      M = "ALT";
      S = "SHIFT";
      L = "LEADER";
    };
    join_mods = m: builtins.concatStringsSep "|" m;
  in {
    homeManager.programs.wezterm = {
      enable = terminal.name == "wezterm";
      settings = {
        enable_wayland = true;
        enable_kitty_keyboard = true;
        adjust_window_size_when_changing_font_size = false;
        freetype_load_target = "Light";
        front_end = "OpenGL";
        # color_scheme = "Gruvbox Material (Gogh)";
        webgpu_power_preference = "HighPerformance";
        default_cursor_style = "BlinkingBlock";
        cursor_blink_rate = 500;
        tab_bar_at_bottom = false;
        use_fancy_tab_bar = true;
        hide_tab_bar_if_only_one_tab = true;
        enable_scroll_bar = true;
        window_decorations = "NONE";
        window_padding = {
          left = terminal.padding;
          right = terminal.padding;
          top = terminal.padding;
          bottom = terminal.padding - terminal.padding;
        };
        leader = {
          key = "q";
          mods = mods.M;
          timeout_milliseconds = 1500;
        };
        keys = [
          {
            key = "n";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.SpawnTab("DefaultDomain")
            '';
          }
          {
            key = "d";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.SpawnTab("CurrentPaneDomain")
            '';
          }
          {
            key = "c";
            mods = mods.L;

            action = lib.generators.mkLuaInline ''
              wezterm.action.CloseCurrentPane({ confirm = true })
            '';
          }
          {
            key = "x";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.CloseCurrentTab({ confirm = true })
            '';
          }
          {
            key = "e";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.PromptInputLine({
                description = "Rename tab",
                action = wezterm.action_callback(function(window, _, line)
                  if line then
                    window:active_tab():set_title(line)
                  end
                end),
              })
            '';
          }
          {
            key = "w";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.PromptInputLine({
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
              })
            '';
          }
          {
            key = "f";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.TogglePaneZoomState
            '';
          }
          {
            key = "\\";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" })
            '';
          }
          {
            key = "]";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.SwitchWorkspaceRelative(1)
            '';
          }
          {
            key = "[";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.SwitchWorkspaceRelative(-1)
            '';
          }
          {
            key = "o";
            mods = mods.L;
            action = "ShowLauncher";
          }
          {
            key = "L";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.SplitHorizontal({
                domain = "CurrentPaneDomain",
              })
            '';
          }
          {
            key = "J";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.SplitVertical({
                domain = "CurrentPaneDomain",
              })
            '';
          }
          {
            key = "l";
            mods = join_mods [mods.M mods.S];
            action = lib.generators.mkLuaInline ''
              wezterm.action.ActivateTabRelative(1)
            '';
          }
          {
            key = "h";
            mods = join_mods [mods.M mods.S];
            action = lib.generators.mkLuaInline ''
              wezterm.action.ActivateTabRelative(-1)
            '';
          }
          {
            key = "h";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.ActivatePaneDirection("Left")
            '';
          }
          {
            key = "l";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.ActivatePaneDirection("Right")
            '';
          }
          {
            key = "k";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.ActivatePaneDirection("Up")
            '';
          }
          {
            key = "j";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.ActivatePaneDirection("Down")
            '';
          }
          {
            key = "c";
            mods = join_mods [mods.C mods.S];
            action = lib.generators.mkLuaInline ''
              wezterm.action.CopyTo("Clipboard")
            '';
          }
          {
            key = "v";
            mods = join_mods [mods.C mods.S];
            action = lib.generators.mkLuaInline ''
              wezterm.action.PasteFrom("Clipboard")
            '';
          }
          {
            key = "p";
            mods = mods.L;
            action = lib.generators.mkLuaInline ''
              wezterm.action.PaneSelect({ alphabet = "123456" })
            '';
          }
          {
            key = "p";
            mods = join_mods [mods.L mods.S];
            action = lib.generators.mkLuaInline ''
              wezterm.action.PaneSelect({ alphabet = "123456", mode = "SwapWithActive" })
            '';
          }
        ];
      };
      # extraConfig = ''
      #   wezterm.on("gui-startup", function(cmd)
      #     local _, _, window = wezterm.mux.spawn_window(cmd or {})
      #     window:gui_window():maximize()
      #   end)
      # '';
    };
  };
}

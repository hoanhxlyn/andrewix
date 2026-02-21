{__findFile, ...}: {
  andrew.editor.provides.zed.homeManager = {pkgs, ...}: {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "biome"
        "mcp-server-context7"
        "mcp-server-brave-search"
        "mcp-server-figma"
      ];
      userKeymaps = [
        {
          "context" = "Editor && vim_mode == insert && !menu";
          "bindings" = {
            "j k" = "vim::NormalBefore";
            "ctrl-s" = "workspace::Save";
          };
        }
        {
          "context" = "Editor && vim_mode == normal && !menu";
          "bindings" = {
            "shift-y" = "vim::YankToEndOfLine";
            # f section
            "space f f" = "file_finder::Toggle";
            "space f c" = "zed::OpenSettingsFile";
            "space f k" = "zed::OpenKeymapFile";
            "space f p" = "projects::OpenRecent";
            "space f l" = "buffer_search::Deploy";
            "space f w" = "pane::DeploySearch";
            "space f t" = "theme_selector::Toggle";
            "space f i" = "icon_theme_selector::Toggle";
            "space f r" = "vim::ToggleRegistersView";
            "space f d" = "diagnostics::Deploy";
            # Buffer
            "shift-l" = "pane::ActivateNextItem";
            "shift-h" = "pane::ActivatePreviousItem";
            "space b d" = "pane::CloseActiveItem";
            "space b o" = "pane::CloseOtherItems";
            "space b L" = "pane::CloseItemsToTheRight";
            "space b H" = "pane::CloseItemsToTheLeft";
            "space b a" = "pane::CloseAllItems";
            "space b l" = "pane::SwapItemRight";
            "space b h" = "pane::SwapItemLeft";
            "space b g" = "pane::JoinAll";
            "space b p" = "pane::TogglePinTab";
            "space b P" = "pane::UnpinAllTabs";
            # LSP
            "space l s" = "outline::Toggle";
            "space l S" = "project_symbols::Toggle";
            "space l d" = "editor::GoToDefinition";
            "space l D" = "editor::GoToDeclaration";
            "space l i" = "editor::GoToImplementation";
            "space l r" = "editor::FindAllReferences";
            "space l t" = "editor::GoToTypeDefinition";
            "space c a" = "editor::ToggleCodeActions";
            "space c r" = "editor::Rename";
            "space c f" = "editor::Format";
            "space c o" = "editor::OrganizeImports";
            # Misc
            "ctrl-a" = "editor::SelectAll";
            "ctrl-s" = "workspace::Save";
            "ctrl-j" = "workspace::ActivatePaneDown";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "space u d" = "editor::ToggleInlineDiagnostics";
            "space u w" = "editor::ToggleSoftWrap";
            "space e" = "pane::RevealInProjectPanel";
            "space t" = "terminal_panel::ToggleFocus";
            "z C" = "editor::FoldAll";
            "z O" = "editor::UnfoldAll";
            "space a a" = "agent::ToggleFocus";
            #Git
            "space g r" = "git::Restore";
            "space g s" = "git::Blame";
            "space g g" = "git_panel::ToggleFocus";
          };
        }
        {
          "context" = "vim_operator == a || vim_operator == i || vim_operator == cs";
          "bindings" = {
            # mini.ai plugin behavior
            "Q" = "vim::MiniQuotes";
            "B" = "vim::MiniBrackets";
          };
        }
        {
          "context" = "Editor && !menu && (vim_mode == visual || vim_mode == normal)";
          "bindings" = {
            "alt-j" = "editor::MoveLineDown";
            "alt-k" = "editor::MoveLineUp";
          };
        }
        # File panel (netrw)
        {
          "context" = "ProjectPanel && not_editing";
          "bindings" = {
            "a" = "project_panel::NewFile";
            "A" = "project_panel::NewDirectory";
            "r" = "project_panel::Rename";
            "d" = "project_panel::Delete";
            "x" = "project_panel::Cut";
            "c" = "project_panel::Copy";
            "p" = "project_panel::Paste";
            "q" = "workspace::ToggleLeftDock";
            "space e" = "workspace::ToggleLeftDock";
            # Navigate between panel
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "ctrl-j" = "workspace::ActivatePaneDown";
          };
        }
        {
          "context" = "Terminal";
          "bindings" = {
            "ctrl-shift-j" = "workspace::ToggleZoom";
            "ctrl-n" = null; # Disable new terminal tab
            "ctrl-p" = null; # Disable open project
            "ctrl-shift-n" = "workspace::NewTerminal";
            "ctrl-w" = "pane::CloseActiveItem";
          };
        }
        {
          "context" = "Agent && not_editing";
          "bindings" = {
            "space q" = "workspace::ToggleLeftDock";
          };
        }
      ];
      userSettings = {
        "auto_signature_help" = false;
        "auto_update" = false;
        "show_signature_help_after_edits" = true;
        "sticky_scroll" = {
          "enabled" = true;
        };
        "preview_tabs" = {
          "enabled" = true;
        };
        "tabs" = {
          "file_icons" = true;
          "close_position" = null;
          "show_diagnostics" = "errors";
          "git_status" = true;
        };
        "buffer_line_height" = "standard";
        "buffer_font_features" = {
          "calt" = true;
        };
        "vim_mode" = true;
        "colorize_brackets" = true;
        "vim" = {
          "highlight_on_yank_duration" = 300;
          "use_smartcase_find" = true;
        };
        "project_panel" = {
          "hide_root" = true;
          "entry_spacing" = "standard";
        };
        "show_whitespaces" = "trailing";
        "bottom_dock_layout" = "full";
        "vertical_scroll_margin" = 3;
        "toolbar" = {
          "quick_actions" = false;
        };
        "terminal" = {
          "copy_on_select" = true;
          "toolbar" = {
            "breadcrumbs" = false;
          };
          "button" = false;
        };
        "completion_menu_scrollbar" = "system";
        "completions" = {
          "lsp_insert_mode" = "replace";
        };
        "debugger" = {
          "dock" = "left";
        };
        "hide_mouse" = "on_typing_and_movement";
        "edit_predictions" = {
          "mode" = "subtle";
        };
        "title_bar" = {
          "show_branch_icon" = true;
        };
        "line_indicator_format" = "short";
        "relative_line_numbers" = "enabled";
        "collaboration_panel" = {
          "button" = false;
        };
        "outline_panel" = {
          "button" = false;
        };
        "git" = {
          "inline_blame" = {
            "delay_ms" = 500;
          };
        };
        "file_finder" = {
          "modal_max_width" = "large";
        };
        # LSP
        "lsp" = {
          "biome" = {
            "settings" = {
              "require_config_file" = true;
            };
          };
          "tailwindcss-language-server" = {
            "settings" = {
              "classFunctions" = [
                "cva"
                "cx"
                "tw"
                "tv"
              ];
            };
          };
        };
        "agent" = {
          "always_allow_tool_actions" = true;
          "default_model" = {
            "provider" = "copilot_chat";
            "model" = "claude-sonnet-4.5";
          };
          "model_parameters" = [];
          "dock" = "left";
        };
        "context_servers" = {
          "mcp-server-brave-search" = {
            "enabled" = true;
            "settings" = {
              "brave_api_key" = "{BRAVE_API_KEY}";
            };
          };
          "serena" = {
            "settings" = {};
            "enabled" = true;
            "headers" = {};
            "url" = "http://localhost:12345/mcp";
          };
          "mcp-server-figma" = {
            "enabled" = true;
            "settings" = {
              "figma_api_key" = "{FIGMA_API_KEY}";
            };
          };
          "mcp-server-context7" = {
            "enabled" = true;
            "settings" = {
              "context7_api_key" = "{CONTEXT_7_API_KEY}";
            };
          };
        };
      };
    };
  };
}

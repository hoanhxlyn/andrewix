{
  core.terminals.kitty = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager = {
      stylix.targets.kitty.variant256Colors = true;
      programs.kitty = {
        enable = terminal.name == "kitty";
        settings = {
          window_padding_width = terminal.padding;
          hide_window_decorations = true;
          confirm_os_window_close = 0;
          shell_integration = "no-cursor";
          cursor_shape = "block";
          cursor_blink_interval = 0;
          mouse_hide_while_typing = true;
          copy_on_select = "clipboard";
          text_composition_strategy = "platform";
        };
        keybindings = {
          # Leader: Alt+q
          "alt+q>n" = "new_tab";
          "alt+q>d" = "new_tab";
          "alt+q>c" = "close_window";
          "alt+q>x" = "close_tab";
          "alt+q>f" = "toggle_layout stack";
          "alt+q>o" = "command_palette";
          # Splits
          "alt+q>shift+l" = "launch --location=hsplit";
          "alt+q>shift+j" = "launch --location=vsplit";
          # Pane navigation
          "alt+q>h" = "previous_window";
          "alt+q>l" = "next_window";
          "alt+q>k" = "previous_window";
          "alt+q>j" = "next_window";
          # Tab navigation
          "alt+shift+l" = "next_tab";
          "alt+shift+h" = "previous_tab";
          # Clipboard
          "ctrl+shift+c" = "copy_to_clipboard";
          "ctrl+shift+v" = "paste_from_clipboard";
        };
      };
    };
  };
}

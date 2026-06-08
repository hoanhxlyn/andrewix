{
  den.aspects.my.terminals.ghostty = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager.programs.ghostty = {
      enable = terminal.name == "ghostty";
      settings = {
        window-padding-x = terminal.padding;
        window-padding-y = builtins.sub terminal.padding terminal.padding;
        window-decoration = "none";
        mouse-hide-while-typing = true;
        copy-on-select = "clipboard";
        background-blur = terminal.opacity < 1;
        background-opacity = terminal.opacity;
        confirm-close-surface = false;
        cursor-style = "block";
        shell-integration-features = false;
        font-feature = "feat on";
        # gtk-wide-tabs = true;
        # gtk-titlebar-style = "tabs";
        # gtk-toolbar-style = "raised";
        # gtk-tabs-location = "top";
        keybind = [
          # Leader: Alt+q
          "alt+q>n=new_tab"
          "alt+q>d=new_tab"
          "alt+q>c=close_surface"
          "alt+q>x=close_tab"
          "alt+q>f=toggle_split_zoom"
          "alt+q>o=toggle_command_palette"
          # Splits
          "alt+q>shift+l=new_split:right"
          "alt+q>shift+j=new_split:down"
          # Pane navigation
          "alt+q>h=goto_split:left"
          "alt+q>l=goto_split:right"
          "alt+q>k=goto_split:up"
          "alt+q>j=goto_split:down"
          # Tab navigation
          "alt+shift+l=next_tab"
          "alt+shift+h=previous_tab"
          # Clipboard
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
        ];
      };
    };
  };
}

{
  core.terminals.alacritty = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager.programs.alacritty = {
      enable = host.defaults.terminal == "alacritty";
      settings = {
        window = {
          padding = {
            x = terminal.padding;
            y = terminal.padding;
          };
          decorations = "None";
          blur = host.appearance.opacity < 1;
        };
        font.builtin_box_drawing = true;
        selection.save_to_clipboard = true;
        terminal.osc52 = "CopyPaste";
        mouse.hide_when_typing = true;
      };
    };
  };
}

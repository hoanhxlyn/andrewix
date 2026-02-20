{
  andrew.terminals.provides.alacritty = terminal: {
    homeManager = {
      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            padding.x = terminal.padding;
            padding.y = terminal.padding;
            decorations = "None";
            blur = true;
            startup_mode = "Maximized";
          };
          font.size = terminal.fontSize;
          selection = {
            save_to_clipboard = true;
          };
          terminal = {
            osc52 = "CopyPaste";
          };
          mouse = {
            hide_when_typing = true;
          };
        };
      };
    };
  };
}

{
  den.aspects.my._.terminals._.alacritty = terminal: {
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

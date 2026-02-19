{__findFile ? __findFile, ...}: {
  andrew.alacritty = terminal:
    <den.lib.parametric> {
      homeManager = {
        programs.alacritty = {
          enable = terminal.whichOne == "alacritty";
          settings = {
            window = {
              padding.x = terminal.padding;
              padding.y = terminal.padding;
              decorations = "None";
              opacity = terminal.opacity;
              blur = true;
              startup_mode = "Maximized";
            };
            font = {
              size = terminal.fontSize;
              normal.family = terminal.fontFamily;
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

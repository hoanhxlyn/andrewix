{
  andrew.terminals.homeManager = {
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          padding.x = 3;
          padding.y = 3;
          decorations = "None";
          opacity = 0.8;
          blur = true;
          startup_mode = "Maximized";
        };
        font = {
          size = 11;
          normal.family = "FiraCode Nerd Font";
          normal.style = "Regular";
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
}

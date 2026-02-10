{
  osConfig,
  lib,
  fontFamily,
  ...
}: {
  config = lib.mkIf (osConfig.aspects.terminalEmulator == "alacritty") {
    programs.alacritty = {
      enable = true;
      theme = "tokyo_night";
      settings = {
        window = {
          padding.x = 3;
          padding.y = 3;
          decorations = "None";
          opacity = 0.9;
          blur = true;
          startup_mode = "Maximized";
        };
        font = {
          size = 12;
          normal.family = "${fontFamily}";
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

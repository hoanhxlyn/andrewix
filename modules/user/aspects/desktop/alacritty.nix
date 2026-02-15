{
  osConfig,
  lib,
  fontFamily,
  ...
}: {
  config = lib.mkIf (osConfig.aspects.terminalEmulator == "alacritty") {
    programs.alacritty = {
      enable = true;
      # theme = "tokyo_night";
      settings = {
        window = {
          padding.x = osConfig.aspects.terminal.padding;
          padding.y = osConfig.aspects.terminal.padding;
          decorations = "None";
          opacity = lib.mkForce osConfig.aspects.terminal.opacity;
          blur = true;
          startup_mode = "Maximized";
        };
        font = {
          size = osConfig.aspects.terminal.fontSize;
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

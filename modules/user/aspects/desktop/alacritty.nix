{
  osConfig,
  lib,
  fontFamily,
  ...
}: {
  programs.alacritty = {
    enable = lib.mkDefault (osConfig.aspects.terminal.whichOne == "alacritty");
    settings = {
      window = {
        padding.x = osConfig.aspects.terminal.padding;
        padding.y = osConfig.aspects.terminal.padding;
        decorations = "None";
        inherit (osConfig.aspects.terminal) opacity;
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
}

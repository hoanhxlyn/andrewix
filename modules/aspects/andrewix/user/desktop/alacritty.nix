{
  osConfig,
  lib,
  ...
}: let
  terminalCfg = osConfig.aspects.terminal or {
    whichOne = "alacritty";
    padding = 2;
    opacity = 0.8;
    fontSize = 10;
  };
in {
  programs.alacritty = {
    enable = lib.mkDefault (terminalCfg.whichOne == "alacritty");
    settings = {
      window = {
        padding.x = terminalCfg.padding;
        padding.y = terminalCfg.padding;
        decorations = "None";
        inherit (terminalCfg) opacity;
        blur = true;
        startup_mode = "Maximized";
      };
      font = {
        size = terminalCfg.fontSize;
        normal.family = "CaskaydiaCove Nerd Font";
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

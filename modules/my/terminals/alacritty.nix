{
  den.aspects.my._.terminals._.alacritty = {host, ...}: let
    terminal = host.terminal;
  in {
    homeManager = {
      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            padding.x = terminal.padding;
            padding.y = builtins.sub terminal.padding terminal.padding;
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

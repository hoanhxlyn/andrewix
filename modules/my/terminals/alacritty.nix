{
  den.aspects.my.terminals.alacritty = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager = {
      programs.alacritty = {
        enable = terminal.name == "alacritty";
        settings = {
          window = {
            padding.x = terminal.padding;
            padding.y = builtins.sub terminal.padding terminal.padding;
            decorations = "None";
            blur = true;
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

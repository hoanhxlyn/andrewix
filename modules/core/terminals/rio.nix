{
  core.terminals.rio = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager = {
      programs.rio = {
        enable = terminal.name == "rio";
        settings = {
          padding-x = terminal.padding;
          padding-y = terminal.padding;
          confirm-before-quit = false;
          cursor = {
            shape = "block";
            blinking = true;
          };
          mouse.hide-when-typing = true;
          window = {
            blur = terminal.opacity < 1;
            opacity-cells = terminal.opacity < 1;
            decorations = "Disabled";
          };
          renderer = {
            use-cpu = true; # ponytail: experimental
          };
          # ponytail: Make rio works like Alacritty
          bindings.keys = [
            {
              key = "c";
              "with" = "control | shift";
              action = "Copy";
            }
            {
              key = "v";
              "with" = "control | shift";
              action = "Paste";
            }
          ];
        };
      };
    };
  };
}

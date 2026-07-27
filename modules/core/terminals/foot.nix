{
  core.terminals.foot = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager = {
      programs.foot = {
        enable = terminal.name == "foot";
        server.enable = true;
        settings = {
          main = {
            pad = "${toString terminal.padding}x${toString terminal.padding}";
          };
          cursor = {
            style = "block";
            blink = "no";
          };
          mouse = {
            hide-when-typing = "yes";
          };
          "colors-dark" = {
            blur =
              if terminal.opacity < 1
              then "yes"
              else "no";
          };
        };
      };
    };
  };
}

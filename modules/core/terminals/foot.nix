{
  core.terminals.foot = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager = {
      programs.foot.enable = host.defaults.terminal == "foot";
      programs.foot.server.enable = true;
      programs.foot.settings = {
        main.pad = "${toString terminal.padding}x${toString terminal.padding}";
        cursor.style = "block";
        cursor.blink = "yes";
        mouse.hide-when-typing = "yes";
        "colors-dark".blur =
          if host.appearance.opacity < 1
          then "yes"
          else "no";
      };
    };
  };
}

{
  core.terminals.rio = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager = {
      programs.rio = {
        enable = host.defaults.terminal == "rio";
        settings = {
          padding-x = terminal.padding;
          padding-y = terminal.padding;
          confirm-before-quit = false;
          copy-on-select = true;
          cursor = {
            shape = "block";
            blinking = true;
          };
          mouse.hide-when-typing = true;
          navigation.hide-if-single = true;
          window = {
            blur = host.appearance.opacity < 1;
            opacity-cells = host.appearance.opacity < 1;
            decorations = "Disabled";
          };
        };
      };
    };
  };
}

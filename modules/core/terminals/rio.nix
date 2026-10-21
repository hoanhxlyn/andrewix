{
  core.terminals.rio = {host, ...}: let
    inherit (host) terminal;
    enable = host.defaults.terminal == "rio";
  in {
    homeManager.programs.rio = {
      inherit enable;
      settings = {
        inherit (terminal) padding;
        confirm-before-quit = false;
        copy-on-select = true;
        hide-mouse-cursor-when-typing = true;
        line-height = 1.1;
        cursor = {
          shape = "block";
          blinking = true;
        };
        navigation = {
          mode = "Plain";
          use-split = false;
          hide-if-single = true;
          unfocused-split-opacity = host.appearance.opacity;
        };
        window = {
          blur = host.appearance.opacity < 1;
          opacity-cells = host.appearance.opacity < 1;
          decorations = "Disabled";
        };
        fonts = {
          regular.weight = 600;
          features = ["calt" "liga"];
        };
      };
    };
  };
}

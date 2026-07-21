{inputs, ...}: {
  flake-file.inputs.rio = {
    url = "github:raphamorim/rio/main";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.terminals.rio = {host, ...}: let
    inherit (host) terminal;
  in {
    homeManager = {pkgs, ...}: {
      programs.rio = {
        enable = terminal.name == "rio";
        package = inputs.rio.packages.${pkgs.system}.rio;
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
          window = {
            blur = terminal.opacity < 1;
            opacity-cells = terminal.opacity < 1;
            decorations = "Disabled";
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

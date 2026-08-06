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
        package = inputs.rio.packages.${pkgs.system}.rio.overrideAttrs (_: {
          doCheck = false;
        });
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
            blur = terminal.opacity < 1;
            opacity-cells = terminal.opacity < 1;
            decorations = "Disabled";
          };
        };
      };
    };
  };
}

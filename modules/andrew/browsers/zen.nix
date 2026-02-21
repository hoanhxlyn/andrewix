{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.zen-browser = {
    url = lib.mkDefault "github:0xc000022070/zen-browser-flake";
    inputs = {
      nixpkgs.follows = lib.mkDefault "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };
  andrew.browsers.provides.zen = {
    homeManager = {pkgs, ...}: let
      keepass = pkgs.keepassxc;
    in {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];
      programs.zen-browser = {
        enable = true;
        nativeMessagingHosts = [keepass];
        profiles.default = {
          id = 0;
          isDefault = true;
          name = "default";
          keyboardShortcuts = [
            {
              id = "zen-compact-mode-toggle";
              key = "\\";
              modifiers = {
                control = true;
                shift = true;
              };
            }
          ];
        };
      };
    };
  };
}

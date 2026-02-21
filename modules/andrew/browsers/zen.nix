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
          mods = [
            "72f8f48d-86b9-4487-acea-eb4977b18f21" # Better ctrl-tab
            "4c2bec61-7f6c-4e5c-bdc6-c9ad1aba1827" # Vertical split tab groups
            "378ba8b9-cd36-45f5-88df-595df5288795" # Add new tab urlbar icon
            "7d577b21-4685-4db2-bb17-d39d08eec199" # Bleeding corners fix
          ];
          settings = {
            # README: need to experiment more
            # General
            "zen.workspaces.continue-where-left-off" = true;
            "browser.translations.neverTranslateLanguages" = "vi";
            "zen.tabs.ctrl-tab.ignore-pending-tabs" = true;
            # Look and feels
            "zen.tabs.show-newtab-vertical" = false;
            "zen.view.show-newtab-button-top" = false;
            "zen.view.compact.enable-at-startup" = true;
            "zen.urlbar.behavior" = true;
            "sidebar.visibility" = "hide-sidebar";
            # Search
            "browser.search.separatePrivateDefault" = false;
          };
          keyboardShortcuts = [
            {
              id = "zen-compact-mode-show-sidebar";
              key = "\\";
              modifiers = {
                control = true;
              };
            }
            {
              id = "zen-compact-mode-shortcut-toggle";
              key = "|";
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

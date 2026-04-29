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
  den.aspects.my._.browsers._.zen.homeManager = {pkgs, ...}: let
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
          "72f8f48d-86b9-4487-acea-eb4977b18f21"
          "4c2bec61-7f6c-4e5c-bdc6-c9ad1aba1827"
          "378ba8b9-cd36-45f5-88df-595df5288795"
          "7d577b21-4685-4db2-bb17-d39d08eec199"
          "5bb07b6e-c89f-4f4a-a0ed-e483cc535594"
          "c01d3e22-1cee-45c1-a25e-53c0f180eea8"
        ];
        settings = {
          "zen.workspaces.continue-where-left-off" = true;
          "browser.translations.neverTranslateLanguages" = "vi";
          "zen.tabs.ctrl-tab.ignore-pending-tabs" = true;
          "zen.tabs.show-newtab-vertical" = false;
          "zen.view.show-newtab-button-top" = false;
          "zen.view.compact.enable-at-startup" = true;
          "zen.view.use-single-toolbar" = false;
          "zen.urlbar.behavior" = "float";
          "sidebar.visibility" = "hide-sidebar";
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
            id = "zen-compact-mode-toggle";
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
}

{
  pkgs,
  lib,
  config,
  ...
}: let
  # Check if keepassxc is enabled in the config
  keepassEnabled = config.programs.keepassxc.enable or false;
  keepass = pkgs.keepassxc;
in {
  programs = {
    firefox = {
      enable = lib.mkDefault true;
      nativeMessagingHosts = lib.optional keepassEnabled keepass;
      profiles.default = {
        id = 0;
        isDefault = true;
        name = "default";
        settings = {
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "expand-on-hover";
          "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
          "sidebar.new-sidebar.has-used" = true;
          "sidebar.animation.expand-on-hover.delay-duration-ms" = 100;
          "sidebar.animation.expand-on-hover.duration-ms" = 100;
        };
      };
    };
    brave = {
      enable = lib.mkDefault true;
      nativeMessagingHosts = lib.optional keepassEnabled keepass;
    };
  };
}

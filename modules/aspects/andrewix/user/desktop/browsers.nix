{
  config,
  pkgs,
  lib,
  ...
}: let
  keepass = pkgs.keepassxc;
in {
  options.modules.desktop.browsers = {
    enable = lib.mkEnableOption "browsers" // {default = true;};
  };

  config = lib.mkIf config.modules.desktop.browsers.enable {
    programs = {
      firefox = {
        enable = true;
        nativeMessagingHosts = [keepass];
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
        enable = true;
        nativeMessagingHosts = [keepass];
      };
    };
  };
}

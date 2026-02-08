{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.desktop.browsers;
  keepass = pkgs.keepassxc;
in {
  options.modules.desktop.browsers = {
    enable = lib.mkEnableOption "browsers";
  };

  config = lib.mkIf cfg.enable {
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

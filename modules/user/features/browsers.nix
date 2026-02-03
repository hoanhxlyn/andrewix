{ pkgs, ... }:
let
  keepass = pkgs.keepassxc;
in
{
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ keepass ];
    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";
      settings = {
        # Enable vertical tabs
        "sidebar.verticalTabs" = true;
        
        # Sidebar hover animation settings
        # Delay before expanding (100ms)
        "sidebar.animation.expand-on-hover.delay-duration-ms" = 100;
        # Duration of the expansion animation (100ms)
        "sidebar.animation.expand-on-hover.duration-ms" = 100;
      };
    };
  };
  programs.brave = {
    enable = true;
    nativeMessagingHosts = [ keepass ];
  };
}

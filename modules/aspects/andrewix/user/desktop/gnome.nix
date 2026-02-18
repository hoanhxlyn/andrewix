{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.aspects.desktop.enable {
    dconf.settings = {
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = true;
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/a11y/interface" = {
        show-status-shapes = false;
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
      };
    };
  };
}

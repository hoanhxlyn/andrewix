{
  core.desktop.notification.dunst = {host, ...}: {
    homeManager = {pkgs, ...}: {
      services.dunst.enable = true;
      services.dunst.iconTheme.package = pkgs.papirus-icon-theme;
      services.dunst.iconTheme.name = "Papirus-Dark";
      services.dunst.settings.global = {
        origin = host.appearance.toast.position;
        offset = let
          x = builtins.mul host.terminal.padding host.appearance.toast.offset.x;
          y = builtins.mul host.terminal.padding host.appearance.toast.offset.y;
        in "${toString x}x${toString y}";
        width = host.appearance.toast.width;
        corner_radius = host.appearance.toast.border.radius;
        frame_width = host.appearance.toast.border.size;
        padding = builtins.mul host.terminal.padding host.appearance.toast.padding.x;
        horizontal_padding = builtins.mul host.terminal.padding host.appearance.toast.padding.y;
        layer = host.appearance.toast.layer;
        markup = "full";
        timeout = host.appearance.toast.timeout / 1000;
        sort = true;
        icon_position = "left";
        history_length = host.appearance.toast.history;
        sticky_history = false;
      };
    };
  };
}

{
  core.desktop.notification.dunst = {host, ...}: {
    homeManager = {pkgs, ...}: {
      gtk.iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };

      services.dunst = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        settings = {
          global = {
            origin = host.toast.position;
            offset = let
              x = builtins.mul host.terminal.padding host.toast.offset.x;
              y = builtins.mul host.terminal.padding host.toast.offset.y;
            in "${toString x}x${toString y}";
            width = host.toast.width;
            corner_radius = host.toast.border.radius;
            frame_width = host.toast.border.size;
            padding = builtins.mul host.terminal.padding host.toast.padding.x;
            horizontal_padding = builtins.mul host.terminal.padding host.toast.padding.y;
            layer = host.toast.layer;
            markup = "full";
            timeout = host.toast.timeout / 1000;
            sort = true;
            icon_position = "left";
            history_length = host.toast.history;
            sticky_history = false;
          };
        };
      };
    };
  };
}

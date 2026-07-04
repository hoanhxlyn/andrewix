{
  core.notification.dunst = {
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
            origin = "top-center";
            width = 400;
            corner_radius = 12;
            frame_width = 2;
            padding = 10;
            horizontal_padding = 15;
            layer = "top";
            markup = "full";
            timeout = 3;
            sort = true;
            icon_position = "left";
            history_length = 50;
            sticky_history = false;
          };
        };
      };
    };
  };
}

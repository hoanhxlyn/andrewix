{
  den.aspects.my.notification.mako = rootConfig: {
    homeManager = {pkgs, ...}: {
      gtk.iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };

      services.mako = {
        enable = true;
        settings = {
          actions = true;
          anchor = "top-center";
          width = 400;
          border-radius = 12;
          border-size = 2;
          padding = "10,15";
          # icons
          max-icon-size = builtins.mul rootConfig.host.terminal.fontSize 2;
          icon-border-radius = 6;
          icons = true;
          icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
          layer = "top";
          markup = true;
          default-timeout = 3000;
          sort = "-time";
          margin = rootConfig.host.terminal.padding;
        };
      };
    };
  };
}

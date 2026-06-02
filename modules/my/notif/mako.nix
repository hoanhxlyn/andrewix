{
  den.aspects.my.notification.mako = rootConfig: {
    homeManager.services.mako = {
      enable = true;
      settings = {
        actions = true;
        height = 150;
        width = 300;
        icons = true;
        layer = "top";
        markup = true;
        default-timeout = 3000;
        sort = "-time";
        margin = rootConfig.host.terminal.padding;
      };
    };
  };
}

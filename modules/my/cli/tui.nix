{__findFile, ...}: {
  den.aspects.my.cli.tui = {
    homeManager = {pkgs, ...}: let
      plug = pkgs.yaziPlugins;
    in {
      programs = {
        yazi = {
          enable = true;
          shellWrapperName = "y";
          plugins = {
            "full-border" = plug.full-border;
            "smart-enter" = plug.smart-enter;
            "lazygit" = plug.lazygit;
          };
        };
      };
      # xdg.configFile."YouTube Music/config.json".force = true;
      # xdg.configFile."YouTube Music/config.json".source = "${self}/config/youtube-music/config.json";
    };
  };
}

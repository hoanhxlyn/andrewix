{
  __findFile,
  lib,
  ...
}: {
  den.aspects.my._.cli._.tui = {self, ...}: {
    homeManager = {pkgs, ...}: let
      plug = pkgs.yaziPlugins;
    in {
      programs = {
        btop = {
          enable = true;
          settings = {
            color_theme = lib.mkDefault "tty";
            theme_background = false;
            vim_keys = true;
            proc_sorting = "memory";
            cpu_single_graph = true;
            show_disks = false;
          };
        };
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

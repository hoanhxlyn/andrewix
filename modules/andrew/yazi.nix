{
  andrew.yazi.homeManager = {pkgs, ...}: let
    plug = pkgs.yaziPlugins;
  in {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      plugins = {
        "full-border" = plug.full-border;
        "smart-enter" = plug.smart-enter;
        "lazygit" = plug.lazygit;
      };
    };
  };
}

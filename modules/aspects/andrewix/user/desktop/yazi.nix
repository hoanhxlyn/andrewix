{
  pkgs,
  lib,
  ...
}: {
  programs.yazi = {
    enable = lib.mkDefault true;
    shellWrapperName = "y";
    plugins = let
      plug = pkgs.yaziPlugins;
    in {
      "full-border" = plug.full-border;
      "smart-enter" = plug.smart-enter;
      "lazygit" = plug.lazygit;
    };
  };
}

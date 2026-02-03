{ pkgs, ... }:
let
  plug = pkgs.yaziPlugins;
in
{
  programs.yazi = {
    enable = true;
    plugins = {
      "full-border" = plug.full-border;
      "smart-enter" = plug.smart-enter;
      "lazygit" = plug.lazygit;
    };
  };
}

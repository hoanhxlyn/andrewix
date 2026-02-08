{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.desktop.yazi;
  plug = pkgs.yaziPlugins;
in {
  options.modules.desktop.yazi = {
    enable = lib.mkEnableOption "yazi";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      plugins = {
        "full-border" = plug.full-border;
        "smart-enter" = plug.smart-enter;
        "lazygit" = plug.lazygit;
      };
    };
  };
}

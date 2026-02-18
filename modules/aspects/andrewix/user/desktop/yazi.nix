{
  config,
  pkgs,
  lib,
  ...
}: let
  plug = pkgs.yaziPlugins;
in {
  options.modules.desktop.yazi = {
    enable = lib.mkEnableOption "yazi" // {default = true;};
  };

  config = lib.mkIf config.modules.desktop.yazi.enable {
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

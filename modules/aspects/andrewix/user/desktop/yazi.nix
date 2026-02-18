{
  pkgs,
  lib,
  ...
}: let
  pluginNames = ["full-border" "smart-enter" "lazygit"];
  yaziPlugins = pkgs.yaziPlugins;
in {
  programs.yazi = {
    enable = lib.mkDefault true;
    shellWrapperName = "y";
    plugins = builtins.listToAttrs (
      map (name: {
        inherit name;
        value = yaziPlugins.${name};
      })
      pluginNames
    );
  };
}

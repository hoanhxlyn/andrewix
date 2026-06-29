{
  lib,
  self,
  __findFile,
  ...
}: {
  den.aspects.my.editor.cursor = {
    includes = [
      (<den.batteries.unfree> ["cursor"])
    ];
    homeManager = {pkgs, ...}: let
      fmt = pkgs.formats.json {};
    in {
      home.packages = [pkgs.code-cursor];

      home.file.".config/Cursor/User/settings.json".source =
        fmt.generate "cursor-settings.json" (lib.importJSON "${self}/config/cursor/settings.json");

      home.file.".config/Cursor/User/keybindings.json".source =
        fmt.generate "cursor-keybindings.json" (lib.importJSON "${self}/config/cursor/keybindings.json");
    };
  };
}

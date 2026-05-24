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
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.code-cursor];

      home.file.".config/Cursor/User/settings.json".text =
        builtins.toJSON (lib.importJSON "${self}/config/cursor/settings.json");

      home.file.".config/Cursor/User/keybindings.json".text =
        builtins.toJSON (lib.importJSON "${self}/config/cursor/keybindings.json");
    };
  };
}

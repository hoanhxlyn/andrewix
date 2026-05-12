{__findFile, ...}: {
  den.aspects.my.editor.cursor = {
    includes = [
      (<den.batteries.unfree> ["cursor"])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.code-cursor
      ];
    };
  };
}

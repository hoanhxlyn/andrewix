{__findFile, ...}: {
  den.aspects.my._.editor._.cursor = {
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

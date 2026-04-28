{__findFile, ...}: {
  den.aspects.andrew._.editor._.cursor = {
    includes = [
      (<den/unfree> ["cursor"])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.code-cursor
      ];
    };
  };
}

{
  mini,
  leaderGroups,
  lib,
}:
lib.optionalAttrs (!mini.clues) {
  enable = true;
  setupOpts = {
    preset = "helix";
    win.col = 0;
  };
  register = lib.listToAttrs (
    map (key: {
      name = "<leader>${key}";
      value = leaderGroups.${key};
    }) (builtins.attrNames leaderGroups)
  );
}

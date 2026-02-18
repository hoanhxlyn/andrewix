{
  inputs,
  den,
  ...
}: {
  andrewix.user.desktop = den.lib.parametric {
    imports = [
      (inputs.import-tree.filterNot (path: baseNameOf path == "default.nix") ./.)
    ];
  };
}

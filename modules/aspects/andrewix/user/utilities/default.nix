{
  inputs,
  den,
  ...
}: {
  andrewix.user.utilities = den.lib.parametric {
    imports = [
      (inputs.import-tree.filterNot (path: baseNameOf path == "default.nix") ./.)
    ];
  };
}

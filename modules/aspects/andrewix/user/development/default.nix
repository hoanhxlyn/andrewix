{
  inputs,
  den,
  ...
}: {
  andrewix.user.development = den.lib.parametric {
    imports = [
      (inputs.import-tree.filterNot (path: baseNameOf path == "default.nix") ./.)
    ];
  };
}

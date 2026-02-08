{inputs, ...}: {
  imports = [
    (inputs.import-tree.filterNot (path: baseNameOf path == "default.nix") ./.)
  ];
}

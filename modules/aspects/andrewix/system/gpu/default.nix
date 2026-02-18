{
  den,
  ...
}: {
  andrewix.system.gpu.nvidia = den.lib.parametric {
    imports = [
      ./nvidia.nix
    ];
  };
}

{
  den,
  ...
}: {
  andrewix.system.utilities = den.lib.parametric {
    imports = [
      ./power-management.nix
    ];
  };
}

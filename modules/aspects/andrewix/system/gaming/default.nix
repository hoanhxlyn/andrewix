{
  den,
  ...
}: {
  andrewix.system.gaming.xone = den.lib.parametric {
    imports = [
      ./xone.nix
    ];
  };

  andrewix.system.gaming.steam = den.lib.parametric {
    imports = [
      ./steam.nix
    ];
  };
}

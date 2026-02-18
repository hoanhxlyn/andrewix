{
  den,
  pkgs,
  ...
}: {
  andrewix.system.desktop = den.lib.parametric {
    imports = [
      ./gnome.nix
      ./communication.nix
    ];
  };
}

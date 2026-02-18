{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    den.url = lib.mkDefault "github:vic/den";
  };
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
}

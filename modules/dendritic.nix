{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    den.url = lib.mkDefault "github:vic/den";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
}

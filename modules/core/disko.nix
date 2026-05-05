{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.disko.nixos = {...}: {
    imports = [
      inputs.disko.nixosModules.default
    ];
  };
}

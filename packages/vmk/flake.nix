{
  description = "fcitx5-vmk - Vietnamese Input Method for Fcitx5";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system} = {
      fcitx5-vmk = pkgs.callPackage ./default.nix {};
      default = pkgs.callPackage ./default.nix {};
    };
  };
}

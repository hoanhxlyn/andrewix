# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Andrewix - Dendritic Configuration";

  outputs = inputs: import ./outputs.nix inputs;

  inputs = {
    aic8800 = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:kurumeii/aic8800-nix";
    };
    fcitx5-vmk-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hoanhxlyn/fcitx5-vmk-nix";
    };
    flake-aspects.url = "github:vic/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:oxalica/rust-overlay";
    };
    serena.url = "github:oraios/serena";
  };
}

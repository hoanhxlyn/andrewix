# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Andrewix - Dendritic Configuration";

  outputs = inputs: import ./outputs.nix inputs;

  inputs = {
    aic8800 = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hoanhxlyn/aic8800-nix";
    };
    chezmoi-nvim = {
      flake = false;
      url = "github:xvzc/chezmoi.nvim";
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
    import-size-nvim = {
      flake = false;
      url = "github:stuckinsnow/import-size.nvim";
    };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:oxalica/rust-overlay";
    };
    serena.url = "github:oraios/serena";
    stylix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/stylix";
    };
    vim-rzip = {
      flake = false;
      url = "github:lbrayner/vim-rzip";
    };
    wezterm-types = {
      flake = false;
      url = "github:justinsgithub/wezterm-types";
    };
  };
}

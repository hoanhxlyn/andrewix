{
  inputs,
  lib,
  ...
}: {
  systems = ["x86_64-linux"];

  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  flake-file = {
    description = "Andrewix - Dendritic Configuration";
    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      den.url = "github:vic/den";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-file.url = "github:vic/flake-file";
      import-tree.url = "github:vic/import-tree";
      flake-aspects.url = "github:vic/flake-aspects";
      serena.url = "github:oraios/serena";
      aic8800 = {
        url = "github:hoanhxlyn/aic8800-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      rust-overlay = {
        url = "github:oxalica/rust-overlay";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      git-hooks-nix.url = "github:cachix/git-hooks.nix";
      fcitx5-vmk-nix = {
        url = "github:hoanhxlyn/fcitx5-vmk-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      stylix = {
        url = "github:nix-community/stylix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      chezmoi-nvim = {
        url = "github:xvzc/chezmoi.nvim";
        flake = false;
      };
      import-size-nvim = {
        url = "github:stuckinsnow/import-size.nvim";
        flake = false;
      };
      wezterm-types = {
        url = "github:justinsgithub/wezterm-types";
        flake = false;
      };
      vim-rzip = {
        url = "github:lbrayner/vim-rzip";
        flake = false;
      };
    };
  };

  pre-commit.settings = {
    hooks = {
      statix.enable = true;
      deadnix.enable = true;
      nixfmt.enable = false;
      alejandra.enable = true;
    };
  };
}

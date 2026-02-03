inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [ "x86_64-linux" ];

  imports = [
    ./modules/flake/hosts.nix
    inputs.flake-file.flakeModules.default
  ];

  flake-file = {
    description = "Andrewix - Dendritic Configuration";
    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
        url = "github:kurumeii/aic8800-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      rust-overlay = {
        url = "github:oxalica/rust-overlay";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };

  perSystem = { system, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = [ pkgs.git pkgs.neovim ];
    };
  };
}

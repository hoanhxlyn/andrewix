# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    den.url = "github:vic/den";
    enthium = {
      flake = false;
      url = "github:sunaku/enthium/v10";
    };
    flake-aspects.url = "github:vic/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    import-tree.url = "github:vic/import-tree";
    nix-auto-follow = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:fzakaria/nix-auto-follow";
    };
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-lib.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
}

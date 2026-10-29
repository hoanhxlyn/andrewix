# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    aic8800 = {
      url = "github:hoanhxlyn/aic8800-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    den.url = "github:denful/den";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dw-proton = {
      url = "github:imaviso/dwproton-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:denful/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    gradient = {
      url = "github:wavelens/gradient";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gruvbox-wallpapers = {
      url = "github:AngelJumbo/gruvbox-wallpapers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr-nix.url = "github:herdrdev/herdr-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mini-nvim = {
      url = "github:nvim-mini/mini.nvim";
      flake = false;
    };
    msi-tui = {
      url = "github:hoanhxlyn/msi-tui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:epireyn/niri-flake";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
    nwm = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omp-yazi = {
      url = "github:saumyajyoti/omp.yazi";
      flake = false;
    };
    opencode = {
      url = "github:anomalyco/opencode/v2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:adomixaszvers/stylix/merged-rofi-settings-font";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tokyonight-wallpapers = {
      url = "github:hoanhxlyn/tokyonight-wallpapers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walls-catppuccin-mocha.url = "github:hoanhxlyn/walls-catppuccin-mocha";
    waycalix.url = "github:hoanhxlyn/waycalix";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
}

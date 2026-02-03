{
  __findFile,
  inputs,
  lib,
  den,
  ...
}: {
  flake-file.inputs = {
    flake-file.url = lib.mkForce "github:denful/flake-file";
    den.url = lib.mkForce "github:denful/den";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
  den = {
    default = {
      includes = [
        <den.batteries.define-user>
        <den.batteries.primary-user>
        <den.batteries.hostname>
        <den.batteries.mutual-provider>
        den.batteries.self'
        den.batteries.inputs'
        <core.nix-setting>
      ];
    };
    schema.user.classes = lib.mkDefault ["homeManager"];
  };
  perSystem = {pkgs, ...}: let
    # Auto-loaded in-repo via .envrc (`use flake`); keeps these out of global closure.
    devPackages = with pkgs; [
      gh
      alejandra
      statix
      deadnix
      just
    ];
  in {
    packages = den.lib.nh.denPackages {fromFlake = true;} pkgs;
    devShells.default = pkgs.mkShell {
      packages = devPackages;
      shellHook = let
        gum = lib.getExe pkgs.gum;
        list = lib.concatMapStringsSep "\n" (p: "• ${p.pname or p.name}") devPackages;
      in ''
        ${gum} style \
          --border rounded --border-foreground 212 --padding "0 2" \
          "$(${gum} style --foreground 212 --bold "Loaded dedicated plugins")" \
          "${list}"
      '';
    };
  };
}

{
  inputs,
  self,
  ...
}: let
  system = "x86_64-linux";
  username = "andrew";
  stateVersion = "25.11";
  fontFamily = "CaskaydiaCove Nerd Font";

  mkSystem = hostName: modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          username
          stateVersion
          fontFamily
          hostName
          self
          ;
        utilsDir = ../utils;
      };
      modules =
        [
          ./hosts/${hostName}/default.nix
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                (import inputs.rust-overlay)
                (_: _: {
                  inherit (inputs.fcitx5-vmk-nix.packages.${system}) fcitx5-vmk;
                })
              ];
              config.allowUnfree = true;
            };

            home-manager = {
              extraSpecialArgs = {
                inherit
                  inputs
                  username
                  stateVersion
                  fontFamily
                  hostName
                  self
                  ;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./user/home.nix;
              backupFileExtension = "backup";
            };
          }
        ]
        ++ modules;
    };
in {
  flake.nixosConfigurations = {
    andrew-pc = mkSystem "andrew-pc" [
      inputs.aic8800.nixosModules.default
    ];

    andrew-laptop = mkSystem "andrew-laptop" [
      inputs.aic8800.nixosModules.default
    ];
  };
}

{
  inputs,
  self,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    mySystem = mkOption {
      type = types.str;
      default = "x86_64-linux";
      description = "The system architecture";
    };

    username = mkOption {
      type = types.str;
      default = "andrew";
      description = "The primary username";
    };

    stateVersion = mkOption {
      type = types.str;
      default = "25.11";
      description = "The state version for NixOS";
    };

    fontFamily = mkOption {
      type = types.str;
      default = "FiraCode Nerd Font";
      description = "The default font family";
    };

    hosts = mkOption {
      type = types.attrsOf (types.listOf types.raw);
      default = {};
      description = "Attribute set of host configurations";
    };
  };

  config = {
    hosts = {
      andrew-pc = [
        inputs.aic8800.nixosModules.default
      ];
      andrew-laptop = [
        inputs.aic8800.nixosModules.default
      ];
    };

    flake.nixosConfigurations = lib.mapAttrs (hostName: modules:
      inputs.nixpkgs.lib.nixosSystem {
        system = config.mySystem;
        specialArgs = {
          inherit
            inputs
            hostName
            self
            ;
          inherit (config) username stateVersion fontFamily;
          utilsDir = ../utils;
        };
        modules =
          [
            ./hosts/${hostName}/default.nix
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs.pkgs = import inputs.nixpkgs {
                system = config.mySystem;
                overlays = [
                  (import inputs.rust-overlay)
                  (_: _: {
                    inherit (inputs.fcitx5-vmk-nix.packages.${config.mySystem}) fcitx5-vmk;
                  })
                ];
                config.allowUnfree = true;
              };

              home-manager = {
                extraSpecialArgs = {
                  inherit
                    inputs
                    hostName
                    self
                    ;
                  inherit (config) username stateVersion fontFamily;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${config.username} = import ./user/home.nix;
                backupFileExtension = "backup";
              };
            }
          ]
          ++ modules;
      })
    config.hosts;
  };
}

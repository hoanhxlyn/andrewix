{
  description = "Andrewix - flake it till we hit it";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aic8800 = {
      url = "github:kurumeii/aic8800-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      homeManager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "andrew";
      stateVersion = "25.11";
      fontFamily = "CaskaydiaCove Nerd Font";
      pkgs = nixpkgs.legacyPackages.${system};

      # Function to create NixOS configuration
      mkSystem =
        hostName: modules:
        nixpkgs.lib.nixosSystem {
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
          };
          modules = [
            ./nixos/hosts/${hostName}/default.nix
            inputs.nvf.nixosModules.default
            homeManager.nixosModules.home-manager
            {
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
                users.${username} = import ./home.nix;
                backupFileExtension = "backup";
              };
            }
          ] ++ modules;
        };
    in
    {
      nixosConfigurations = {
        # PC Configuration (Nvidia)
        andrew-pc = mkSystem "andrew-pc" [ ];

        # Laptop Configuration
        andrew-laptop = mkSystem "andrew-laptop" [
          inputs.aic8800.nixosModules.default
        ];
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            nodejs
          ];
        };
      };
    };
}

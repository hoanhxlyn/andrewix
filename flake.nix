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
      hostName = "andrewix";
      stateVersion = "25.11";
      fontFamily = "CaskaydiaCove Nerd Font";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            username
            hostName
            stateVersion
            fontFamily
            self
            ;
        };
        modules = [
          ./nixos/configuration.nix
          inputs.nvf.nixosModules.default
          homeManager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit
                  inputs
                  username
                  hostName
                  stateVersion
                  fontFamily
                  self
                  ;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home.nix;
              backupFileExtension = "backup";
            };
          }
          # Use AIC8800 module from local repository
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

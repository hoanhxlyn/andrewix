{
  den,
  inputs,
  ...
}: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  den = {
    ctx.hm-host.includes = [
      ({pkgs, ...}: {
        home.packages = [
          inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      })
    ];
  };
}

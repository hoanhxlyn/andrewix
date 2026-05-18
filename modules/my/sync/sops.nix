{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  den.aspects.my.sync.sops.homeManager = {config, ...}: let
    keyFile = "${config.home.homeDirectory}/.config/sops-nix/keys.txt";
  in {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];
    sops = {
      defaultSopsFile = "${self}/secrets/secrets.yaml";
      defaultSopsFormat = "yaml";
      age.keyFile = keyFile;
      secrets = {
        CONTEXT7_API_KEY = {};
        TAVILY_API_KEY = {};
      };
    };
  };
}

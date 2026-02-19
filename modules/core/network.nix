{inputs, ...}: {
  flake-file.inputs = {
    aic8800.url = "github:hoanhxlyn/aic8800-nix";
  };
  core.network.nixos = {lib, ...}: {
    imports = [
      inputs.aic8800.nixosModules.default
    ];
    networking.networkmanager = {
      enable = true;
      appendNameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4"];
    };
  };
}

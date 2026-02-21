{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.aic8800.url = lib.mkDefault "github:hoanhxlyn/aic8800-nix";
  core.wifi.nixos = {
    imports = [
      inputs.aic8800.nixosModules.default
    ];
    hardware.aic8800.enable = true;
  };
}

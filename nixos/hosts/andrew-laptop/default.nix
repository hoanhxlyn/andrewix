{ username, pkgs, ... }:

{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  # Laptop specific hardware
  hardware.aic8800.enable = true;
  networking.hostName = "andrew-laptop";
}

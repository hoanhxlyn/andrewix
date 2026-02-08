{...}: {
  imports = [
    ../../system/configuration.nix
    ./hardware-configuration.nix
  ];

  hardware.aic8800.enable = true;
  networking.hostName = "andrew-laptop";
}

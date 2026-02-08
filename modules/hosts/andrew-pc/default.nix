{...}: {
  imports = [
    ../../system/configuration.nix
    ../../system/aspects/gpu/nvidia.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "andrew-pc";
  hardware.aic8800.enable = true;
}

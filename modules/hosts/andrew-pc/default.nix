{...}: {
  imports = [
    ../../system/configuration.nix
    ../../system/aspects/gpu/nvidia.nix
    ../../system/aspects/gaming
    ./hardware-configuration.nix
  ];

  networking.hostName = "andrew-pc";
  hardware.aic8800.enable = true;
}

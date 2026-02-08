{...}: {
  imports = [
    ../../system/configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "andrew-pc";
  hardware.aic8800.enable = true;

  # Enable PC-specific aspects
  aspects = {
    gpu.nvidia.enable = true;
    gaming.xone.enable = true;
  };
}

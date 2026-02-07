{config, ...}: {
  imports = [
    ../../system/configuration.nix
    # README: Copy the real config
    # ./hardware-configuration.nix
  ];

  networking.hostName = "andrew-pc";

  # Nvidia Configuration
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}

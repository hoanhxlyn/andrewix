{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aspects.gpu.nvidia.enable {
    hardware = {
      graphics.enable = true;

      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}

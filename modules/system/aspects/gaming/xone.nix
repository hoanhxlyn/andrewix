{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aspects.gaming.xone.enable {
    # Xbox One controller driver
    hardware.xone.enable = true;

    # udev rules for game devices (controllers, joysticks, etc)
    services.udev.packages = [pkgs.game-devices-udev];
  };
}

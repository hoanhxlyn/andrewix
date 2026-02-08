{pkgs, ...}: {
  # Xbox One controller driver
  hardware.xone.enable = true;

  # udev rules for game devices (controllers, joysticks, etc)
  services.udev.packages = [pkgs.game-devices-udev];
}

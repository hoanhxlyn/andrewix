{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aspects.gaming.xone.enable {
    # Xbox One controller driver
    hardware.xone.enable = true;

    # udev rules to give user access to game controllers/joysticks
    services.udev.extraRules = ''
      # Allow user access to joystick devices
      SUBSYSTEM=="input", ENV{ID_INPUT_JOYSTICK}=="?*", TAG="uaccess"

      # Xbox controller specific rules
      KERNEL=="js[0-9]*", TAG="uaccess"
      KERNEL=="event[0-9]*", TAG="uaccess"
    '';
  };
}

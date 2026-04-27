{__findFile, ...}: {
  den.aspects.andrew._.gaming._.xone = {
    includes = [
      (<den/unfree> [
        "xone-dongle-firmware"
      ])
    ];
    nixos = {
      hardware.xone.enable = true;
      services.udev.extraRules = ''
        SUBSYSTEM=="input", ENV{ID_INPUT_JOYSTICK}=="?*", TAG="uaccess"
        KERNEL=="js[0-9]*", TAG="uaccess"
        KERNEL=="event[0-9]*", TAG="uaccess"
      '';
    };
  };
}

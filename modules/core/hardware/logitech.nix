{
  core.hardware.logitech = {
    nixos = {
      hardware.logitech.wireless.enable = true;
      programs.solaar = {
        enable = true;
        userService = {
          enable = true;
          window = "hide";
        };
      };
    };
  };
}

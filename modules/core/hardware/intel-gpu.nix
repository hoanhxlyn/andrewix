{
  core.hardware.intel-gpu = {
    nixos = {pkgs, ...}: {
      hardware.graphics.enable = true;
      hardware.graphics.extraPackages = [pkgs.intel-media-driver];
      environment.variables.LIBVA_DRIVER_NAME = "iHD";
    };
  };
}

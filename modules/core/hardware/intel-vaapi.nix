{
  core.hardware.intel-vaapi = {
    nixos = {pkgs, ...}: {
      hardware.graphics = {
        enable = true;
        extraPackages = [pkgs.intel-media-driver];
      };
      environment.variables = {
        LIBVA_DRIVER_NAME = "iHD";
      };
    };
  };
}

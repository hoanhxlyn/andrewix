{
  den,
  pkgs,
  ...
}: {
  andrewix.system.core.boot = den.lib.parametric {
    config = {
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        supportedFilesystems = ["fuse"];
        kernelPackages = pkgs.linuxPackages_latest;
      };
    };
  };
}

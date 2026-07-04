{
  core.bootable = {host, ...}: {
    nixos = {pkgs, ...}: {
      boot = {
        loader.systemd-boot.enable = host.isLaptop;
        loader.grub = {
          enable = !host.isLaptop;
          efiSupport = true;
          device = "nodev";
          useOSProber = true;
          configurationLimit = 3;
        };
        loader.efi.canTouchEfiVariables = true;

        extraModprobeConfig = "options hid_apple fnmode=2";
        supportedFilesystems = ["fuse"];
        kernelPackages = pkgs.linuxPackages_latest;
        plymouth.enable = true;
      };
      stylix.targets.grub.useWallpaper = true;
    };
  };
}

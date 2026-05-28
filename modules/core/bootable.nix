{
  core.bootable.nixos = {pkgs, ...}: {
    boot = {
      loader = {
        systemd-boot.enable = false;
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
          useOSProber = true;
          configurationLimit = 3;
        };
        efi.canTouchEfiVariables = true;
      };
      extraModprobeConfig = "options hid_apple fnmode=2";
      supportedFilesystems = ["fuse"];
      kernelPackages = pkgs.linuxPackages_latest;
      plymouth.enable = true;
    };
  };
}

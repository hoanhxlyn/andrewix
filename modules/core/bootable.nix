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
      supportedFilesystems = ["fuse"];
      kernelPackages = pkgs.linuxPackages_latest;
      plymouth.enable = true;
    };
  };
}

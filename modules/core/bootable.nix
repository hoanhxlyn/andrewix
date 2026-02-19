{
  core.bootable.nixos = {pkgs, ...}: {
    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      supportedFilesystems = ["fuse"];
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}

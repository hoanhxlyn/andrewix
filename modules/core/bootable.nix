{
  core.bootable.nixos = {pkgs, ...}: {
    boot = {
      loader.systemd-boot = {
        enable = true;
        configurationLimit = 5; # Keep at most 5 generations
      };
      loader.efi.canTouchEfiVariables = true;
      supportedFilesystems = ["fuse"];
      kernelPackages = pkgs.linuxPackages_latest;
      plymouth.enable = true;
    };
  };
}

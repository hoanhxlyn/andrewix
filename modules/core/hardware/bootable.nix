{
  core.bootable = {
    host,
    user,
    ...
  }: {
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

        # loglevel=3: keep kernel err/warn (e.g. usb 1-10 enum failures) off the
        # VT so they stop painting over the ly greeter. Journal still records them.
        consoleLogLevel = 3;
        extraModprobeConfig = "options hid_apple fnmode=2";
        supportedFilesystems = ["fuse"];
        kernelPackages = pkgs.linuxPackages_latest;
        plymouth.enable = true;
      };
      stylix.targets.grub.useWallpaper = true;

      users.users.${user.userName}.initialPassword = host.initialPassword;
    };
  };
}

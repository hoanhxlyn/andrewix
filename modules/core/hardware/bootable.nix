{
  core.hardware.bootable = {host, ...}: {
    nixos = {
      config,
      lib,
      modulesPath,
      pkgs,
      ...
    }: {
      # Shared hardware profiles of the two physical hosts (Intel CPU, NVMe via
      # VMD). vmd is not in NixOS' defaults, so without it initrd can't see the
      # NVMe root. Kept here after hosts/<host>/_nixos/ was removed.
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd.availableKernelModules = [
          "vmd"
          "ahci"
          "xhci_pci"
          "nvme"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = ["kvm-intel"];
        loader.systemd-boot.enable = host.bootLoader == "systemd-boot";
        loader.grub = {
          enable = host.bootLoader == "grub";
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
      hardware.cpu.intel.updateMicrocode =
        lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}

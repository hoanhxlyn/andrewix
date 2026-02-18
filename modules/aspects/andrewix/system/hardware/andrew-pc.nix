{
  config,
  lib,
  modulesPath,
  den,
  ...
}: {
  andrewix.system.hardware.andrew-pc = den.lib.parametric {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    config = {
      boot = {
        initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
        initrd.kernelModules = [];
        kernelModules = ["kvm-intel"];
        extraModulePackages = [];
      };

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/a314a0b5-2cca-4fae-8b47-ce14f2f9a4fd";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/E2C0-5C9B";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      swapDevices = [
        {device = "/dev/disk/by-uuid/2bb13172-d6ac-47aa-a06b-6c797f1e0912";}
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}

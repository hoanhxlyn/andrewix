{
  core.hardware.bootable = {host, ...}: {
    nixos = {
      config,
      lib,
      modulesPath,
      pkgs,
      ...
    }: {
      # Shared hardware profile of the physical hosts (NVMe via VMD). CPU vendor
      # (kvm module, microcode) is per-host from the `cpu` fact. vmd is not in
      # NixOS' defaults, so without it initrd can't see the NVMe root. Kept here
      # after hosts/<host>/_nixos/ was removed.
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
        kernelModules = ["kvm-${host.cpu}"];
        loader.systemd-boot.enable = host.bootLoader == "systemd-boot";
        # kernels + initrd get copied onto the ESP (limine can't read XFS root);
        # maxGenerations null = unbounded, which fills the 512M ESP.
        loader.limine = {
          enable = host.bootLoader == "limine";
          maxGenerations = 4;
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
      hardware.cpu = {
        intel.updateMicrocode =
          lib.mkDefault (host.cpu == "intel" && config.hardware.enableRedistributableFirmware);
        amd.updateMicrocode =
          lib.mkDefault (host.cpu == "amd" && config.hardware.enableRedistributableFirmware);
      };
    };
  };
}

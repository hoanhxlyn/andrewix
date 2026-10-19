{__findFile, ...}: {
  core.hardware.nvidia = {
    includes = [
      (<den.batteries.unfree> [
        "nvidia-x11"
        "nvidia-settings"
        "nvidia-kernel-modules"
      ])
    ];

    nixos = {
      config,
      host,
      lib,
      ...
    }: let
      gpus = host.gpu or [];
      nvidiaGpu = lib.findFirst (g: g.vendor == "nvidia") null gpus;
      intelGpu = lib.findFirst (g: g.vendor == "intel" && g.kind == "integrated") null gpus;
      hybrid = nvidiaGpu != null && intelGpu != null;
      prime = lib.optionalAttrs (hybrid && nvidiaGpu.busId != null && intelGpu.busId != null) {
        intelBusId = intelGpu.busId;
        nvidiaBusId = nvidiaGpu.busId;
      };
      primeReady = prime != {};
    in {
      warnings = lib.optional (hybrid && !primeReady) ''
        ${host.name or "host"}: hybrid Intel+NVIDIA but a `gpu` entry has no `busId` in
        modules/hosts.nix; PRIME offload is disabled until they are filled in.
      '';

      boot = {
        kernelParams = ["nvidia-drm.fbdev=1"];
        # No nvidia modules in initrd (early KMS): with
        # NVreg_PreserveVideoMemoryAllocations=1 an early-loaded driver restores
        # VRAM itself before nvidia-resume runs, and resume from hibernation
        # hangs at the plymouth splash. nixpkgs loads the modules from udev in
        # stage 2 (boot.kernelModules); the splash just runs on simpledrm.
        extraModprobeConfig = ''
          options nvidia NVreg_PreserveVideoMemoryAllocations=1
          options nvidia NVreg_EnableGpuFirmware=0
        '';
      };
      # Hybrid: niri/desktop run on the Intel iGPU; games opt in to the nvidia dGPU with
      # `nvidia-offload <cmd>` (Steam launch option). PRIME sync is X11-only, so offload is used.
      # `modesetting` first, as the NixOS wiki advises for offload.
      # Every output (panel + HDMI) sits on the Intel iGPU, so niri needs no `render-drm-device`.
      services.xserver.videoDrivers = lib.optional hybrid "modesetting" ++ ["nvidia"];
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };
        nvidia = {
          open = false;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
          powerManagement.enable = true;
          powerManagement.finegrained = false;
          modesetting.enable = true;
          nvidiaPersistenced = true;
          prime = lib.mkIf primeReady ({
              offload = {
                enable = true;
                enableOffloadCmd = true; # adds `nvidia-offload`
              };
            }
            // prime);
        };
      };
    };
  };
}

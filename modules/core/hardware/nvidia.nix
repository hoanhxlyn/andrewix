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
      hybrid = lib.elem "intel" (host.gpu or []);
      prime = host.nvidiaPrime or null;
    in {
      warnings = lib.optional (hybrid && prime == null) ''
        ${host.name or "host"}: hybrid Intel+NVIDIA but `nvidiaPrime` bus IDs are unset in
        modules/hosts.nix; PRIME offload is disabled until they are filled in.
      '';

      boot = {
        kernelParams = ["nvidia-drm.fbdev=1"];
        # Only when nvidia is the active driver: VM builds override videoDrivers
        # to modesetting and ship no nvidia module for initrd. Hybrid hosts skip
        # it so the Intel iGPU stays the boot GPU the compositor picks.
        initrd.kernelModules = lib.optionals (!hybrid && lib.elem "nvidia" config.services.xserver.videoDrivers) [
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];
        extraModprobeConfig = ''
          options nvidia NVreg_PreserveVideoMemoryAllocations=1
          options nvidia NVreg_EnableGpuFirmware=0
        '';
      };
      # Hybrid: niri/desktop run on the Intel iGPU; games opt in to the nvidia dGPU with
      # `nvidia-offload <cmd>` (Steam launch option). PRIME sync is X11-only, so offload is used.
      # `modesetting` first, as the NixOS wiki advises for offload.
      # TODO: If external ports are wired to the nvidia GPU and stay dark under offload, set niri
      # `debug { render-drm-device "/dev/dri/renderD<n>"; }` to the nvidia node (experimental) or
      # drop `prime` for that host. Unverified on Wayland; test after install.
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
          prime = lib.mkIf (hybrid && prime != null) {
            offload = {
              enable = true;
              enableOffloadCmd = true; # adds `nvidia-offload`
            };
            inherit (prime) intelBusId nvidiaBusId;
          };
        };
      };
      systemd.services.gdm-nvidia-wayland = {
        before = ["display-manager.service"];
        wantedBy = ["display-manager.service"];
        script = ''
          mkdir -p /run/gdm/runtime-config/daemon
          echo true > /run/gdm/runtime-config/daemon/WaylandEnable
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };
  };
}

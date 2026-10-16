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
        modules/hosts.nix; PRIME sync is disabled until they are filled in.
      '';

      boot = {
        kernelParams = ["nvidia-drm.fbdev=1"];
        # Only when nvidia is the active driver: VM builds override videoDrivers
        # to modesetting and ship no nvidia module for initrd.
        initrd.kernelModules = lib.optionals (lib.elem "nvidia" config.services.xserver.videoDrivers) [
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
      # TODO: PRIME sync is X11-style. After install, check niri on this host and, if needed, set its
      # render device to the nvidia GPU (derive the /dev/dri/by-path from `nvidiaPrime.nvidiaBusId`).
      services.xserver.videoDrivers = ["nvidia"];
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
          # Optimus laptop: nvidia renders, intel only scans out the internal panel.
          prime = lib.mkIf (hybrid && prime != null) {
            sync.enable = true;
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

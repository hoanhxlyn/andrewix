{__findFile, ...}: {
  core.nvidia = {
    includes = [
      (<den.batteries.unfree> [
        "nvidia-x11"
        "nvidia-settings"
        "nvidia-kernel-modules"
      ])
    ];

    nixos = {config, ...}: {
      boot = {
        kernelParams = ["nvidia-drm.fbdev=1"];
        initrd.kernelModules = [
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];
        extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
        extraModprobeConfig = ''
          options nvidia NVreg_PreserveVideoMemoryAllocations=1
          options nvidia NVreg_EnableGpuFirmware=0
        '';
      };
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

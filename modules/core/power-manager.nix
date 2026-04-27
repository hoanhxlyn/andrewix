{lib, ...}: {
  core.power-manager.nixos = {config, ...}: {
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
      ];
      kernelModules = ["acpi_call"];
    };

    services = {
      power-profiles-daemon.enable = lib.mkForce false;
      tlp = {
        enable = true;
        settings = {
          # CPU
          CPU_SCALING_GOVERNOR_ON_AC = "powersave";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_SAV = "power";
          CPU_BOOST_ON_BAT = 0;

          # Platform Profiles
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";
          PLATFORM_PROFILE_ON_SAV = "low-power";

          # Battery Charge Thresholds
          START_CHARGE_THRESH_BAT0 = 40;
          STOP_CHARGE_THRESH_BAT0 = 80;
          RESTORE_THRESHOLDS_ON_BAT = 1;

          # PCIE & Runtime PM
          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";
          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";

          # Peripherals
          USB_AUTOSUSPEND = 0;
        };
      };
    };
  };
}

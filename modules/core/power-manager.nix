{
  core.power-manager.nixos = {
    services = {
      power-profiles-daemon.enable = false;
      tlp = {
        enable = true;
        settings = {
          start_charge_thresh_bat0 = 40;
          stop_charge_thresh_bat0 = 90;

          # cpu
          cpu_scaling_governor_on_ac = "powersave";
          cpu_scaling_governor_on_bat = "powersave";
          cpu_energy_perf_policy_on_ac = "balance_performance";
          cpu_energy_perf_policy_on_bat = "power";
          cpu_boost_on_bat = 0;
          platform_profile_on_ac = "performance";
          platform_profile_on_bat = "low-power";

          # pcie & runtime pm
          pcie_aspm_on_ac = "default";
          pcie_aspm_on_bat = "powersupersave";
          runtime_pm_on_ac = "on";
          runtime_pm_on_bat = "auto";

          # peripherals
          usb_autosuspend = 0;
        };
      };
    };
  };
}

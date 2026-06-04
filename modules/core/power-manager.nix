{lib, ...}: {
  core.power-manager.nixos = {
    config,
    pkgs,
    ...
  }: {
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
      ];
      kernelModules = ["acpi_call"];
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        var cmd = action.lookup("command_line");
        if (
          action.id == "org.freedesktop.policykit.exec" &&
          subject.isInGroup("wheel") &&
          action.lookup("program") == "${pkgs.tlp}/bin/tlp" &&
          (cmd.indexOf(" performance") != -1 ||
           cmd.indexOf(" balanced") != -1 ||
           cmd.indexOf(" power-saver") != -1)
        ) {
          return polkit.Result.YES;
        }
      });
    '';

    services = {
      power-profiles-daemon.enable = lib.mkForce false;
      upower.enable = true;
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
          PLATFORM_PROFILE_ON_BAT = "balanced";
          PLATFORM_PROFILE_ON_SAV = "quiet";

          # Battery Charge Thresholds
          START_CHARGE_THRESH_BAT0 = 40;
          STOP_CHARGE_THRESH_BAT0 = 85;
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

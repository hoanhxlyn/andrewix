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

    # asus_wmi registers charge_control_end_threshold but its WMI GET returns
    # ENODATA on X1405VA, causing TLP's readable_sysf check to fail and skip
    # threshold setting entirely. Write directly at boot as a workaround.
    systemd.services.battery-charge-threshold = {
      description = "Set battery charge stop threshold";
      wantedBy = ["multi-user.target"];
      after = ["systemd-modules-load.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c 'echo 85 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";
        RemainAfterExit = true;
      };
    };

    services = {
      power-profiles-daemon.enable = lib.mkForce false;
      upower.enable = true;
      logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchDocked = "ignore";
        IdleAction = "ignore";
        IdleActionSec = "30min";
      };

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

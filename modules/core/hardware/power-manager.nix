{
  core.hardware.power-manager = {
    nixos = {
      config,
      host,
      lib,
      ...
    }: let
      ct = host.chargeThreshold;
      # The GF63 Thin 10SC (16R5EMS1) is absent from the in-tree msi-ec
      # allowlist, so pull the out-of-tree driver from nixpkgs. Its ACPI battery
      # hook registers the standard charge_control sysfs on the battery (BAT1).
      msiEc = ct != null && ct.msiEc;
    in {
      boot = {
        extraModulePackages = lib.optional msiEc config.boot.kernelPackages.msi-ec;
        kernelModules = lib.optional msiEc "msi-ec";
      };

      # Allow wheel to flip TLP power profiles without a password. Scoped to the
      # exact three subcommands; sudo already has a working setuid wrapper here
      # (pkexec does not), so this is the reliable escalation path.
      security.sudo.extraRules = [
        {
          groups = ["wheel"];
          commands = map (p: {
            command = "/run/current-system/sw/bin/tlp ${p}";
            options = ["NOPASSWD"];
          }) ["performance" "balanced" "power-saver"];
        }
      ];

      # asus_wmi registers charge_control_end_threshold but its WMI GET returns
      # ENODATA on X1405VA, causing TLP's readable_sysf check to fail and skip
      # threshold setting entirely; the msi-ec driver needs the same direct write
      # (and only `stop` — the EC derives start). Write at boot. Only for hosts
      # that declare `chargeThreshold`.
      systemd.services.battery-charge-threshold = lib.mkIf (ct != null) {
        description = "Set battery charge stop threshold";
        wantedBy = ["multi-user.target"];
        after = ["systemd-modules-load.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        # Battery name is per driver: asus_wmi uses BAT0, msi-ec uses BAT1.
        script =
          if msiEc
          then "echo ${toString ct.stop} > /sys/class/power_supply/BAT1/charge_control_end_threshold"
          else "echo ${toString ct.stop} > /sys/class/power_supply/BAT0/charge_control_end_threshold";
      };

      services = {
        power-profiles-daemon.enable = false;
        upower.enable = true;
        logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchDocked = "ignore";
          HandlePowerKey = "hibernate";
          IdleAction = "ignore";
          IdleActionSec = "30min";
        };

        tlp = {
          enable = true;
          settings =
            {
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

              # PCIE & Runtime PM
              PCIE_ASPM_ON_AC = "default";
              PCIE_ASPM_ON_BAT = "powersupersave";
              RUNTIME_PM_ON_AC = "on";
              RUNTIME_PM_ON_BAT = "auto";

              # Peripherals
              USB_AUTOSUSPEND = 0;
            }
            // lib.optionalAttrs (ct != null && !msiEc) {
              # Battery Charge Thresholds (asus_wmi; the msi-ec path is set by
              # the oneshot above and derives its own start).
              START_CHARGE_THRESH_BAT0 = ct.start;
              STOP_CHARGE_THRESH_BAT0 = ct.stop;
              RESTORE_THRESHOLDS_ON_BAT = 1;
            };
        };
      };
    };
  };
}

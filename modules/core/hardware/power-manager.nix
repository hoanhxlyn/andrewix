{
  core.hardware.power-manager = {
    nixos = {
      config,
      host,
      lib,
      pkgs,
      ...
    }: let
      ct = host.chargeThreshold;
      # MSI ECs expose no charge_control sysfs (the mainline msi-ec driver does
      # not cover every model), so the limit is written to the EC byte directly.
      ecReg =
        if ct == null
        then null
        else ct.ecRegister;
    in {
      boot = {
        extraModulePackages = with config.boot.kernelPackages; [
          acpi_call
        ];
        kernelModules = ["acpi_call"] ++ lib.optional (ecReg != null) "ec_sys";
        # ec_sys is read-only unless write_support is set.
        extraModprobeConfig = lib.optionalString (ecReg != null) "options ec_sys write_support=1\n";
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
      # threshold setting entirely. Write directly at boot as a workaround.
      # MSI has no such sysfs at all, so write the EC byte (`stop + 0x80`) via
      # the ec_sys debugfs instead. Only for hosts that declare `chargeThreshold`.
      systemd.services.battery-charge-threshold = lib.mkIf (ct != null) {
        description = "Set battery charge stop threshold";
        wantedBy = ["multi-user.target"];
        after = ["systemd-modules-load.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = lib.optionals (ecReg != null) [pkgs.coreutils];
        script =
          if ecReg == null
          then "echo ${toString ct.stop} > /sys/class/power_supply/BAT0/charge_control_end_threshold"
          else ''
            dev=/sys/kernel/debug/ec/ec0/io
            # Only touch a register already holding a charge byte (0x8a..0xe4),
            # so a wrong address cannot clobber unrelated EC state.
            cur=$(dd if="$dev" bs=1 skip=${toString ecReg} count=1 2>/dev/null | od -An -tu1 | tr -dc '0-9')
            [ -n "$cur" ] && [ "$cur" -ge 138 ] && [ "$cur" -le 228 ] || exit 1
            printf "\\$(printf '%03o' $(( ${toString ct.stop} + 128 )))" |
              dd of="$dev" bs=1 seek=${toString ecReg} conv=notrunc status=none
          '';
      };

      services = {
        power-profiles-daemon.enable = false;
        upower.enable = true;
        logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchDocked = "ignore";
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
            // lib.optionalAttrs (ct != null && ecReg == null) {
              # Battery Charge Thresholds (ThinkPad/acpi_call; not an MSI path)
              START_CHARGE_THRESH_BAT0 = ct.start;
              STOP_CHARGE_THRESH_BAT0 = ct.stop;
              RESTORE_THRESHOLDS_ON_BAT = 1;
            };
        };
      };
    };
  };
}

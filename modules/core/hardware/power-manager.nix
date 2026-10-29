{inputs, ...}: {
  flake-file.inputs.msi-tui = {
    url = "github:hoanhxlyn/msi-tui";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.hardware.power-manager = {
    # This aspect is only included for laptops (modules/core/hardware/default.nix).
    homeManager = {pkgs, ...}: let
      tlp = "/run/current-system/sw/bin/tlp";
      capacity = "${pkgs.coreutils}/bin/cat";
      # Below this state of charge, discharging switches to power-saver once and
      # nags for the charger. TLP restores the AC profile on plug-in by itself.
      lowBattery = 40;
      batteryLow = pkgs.writeShellScript "battery-low-profile" ''
        while :; do
          for bat in /sys/class/power_supply/BAT*; do
            [ "$(${capacity} "$bat/status")" = Discharging ] || continue
            cap=$(${capacity} "$bat/capacity")
            [ "$cap" -le ${toString lowBattery} ] || continue
            # Already throttled for this discharge; avoid a notification every minute.
            ${tlp}-stat -m 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q '^power-saver' && continue
            /run/wrappers/bin/sudo -n ${tlp} power-saver \
              && ${pkgs.libnotify}/bin/notify-send -u critical "Battery ''${cap}%" "Plug in the charger"
          done
          ${pkgs.coreutils}/bin/sleep 60
        done
      '';
    in {
      systemd.user.services.battery-low-profile.Unit.Description = "Switch TLP to power-saver at ${toString lowBattery}% battery";
      systemd.user.services.battery-low-profile.Install.WantedBy = ["default.target"];
      systemd.user.services.battery-low-profile.Service.ExecStart = "${batteryLow}";
      systemd.user.services.battery-low-profile.Service.Restart = "on-failure";
      systemd.user.services.battery-low-profile.Service.RestartSec = 30;
    };

    nixos = {
      config,
      host,
      lib,
      pkgs,
      ...
    }: let
      ct = host.chargeThreshold;
      # The GF63 Thin 10SC (16R5EMS1) is absent from the in-tree msi-ec
      # allowlist, so pull the out-of-tree driver from nixpkgs. Its ACPI battery
      # hook registers the standard charge_control sysfs on the battery (BAT1).
      msiEc = ct != null && ct.msiEc;
      msiEcCtl = "/run/current-system/sw/bin/msi-ec-ctl";
      fanModes = ["auto" "silent" "basic" "advanced"];
      shiftModes = ["eco" "comfort" "sport" "turbo"];
    in {
      boot.extraModulePackages = lib.optional msiEc config.boot.kernelPackages.msi-ec;
      boot.kernelModules = lib.optional msiEc "msi-ec";

      # msi-tui writes fan/shift/boost modes through this; values are checked
      # again below so the sudo whitelist and the driver agree.
      environment.systemPackages = lib.optionals msiEc [
        (pkgs.writeShellScriptBin "msi-ec-ctl" ''
          set -eu
          dir=/sys/devices/platform/msi-ec
          usage() {
            echo "usage: msi-ec-ctl fan-mode <m> | shift-mode <m> | cooler-boost <on|off>" >&2
            exit 2
          }
          [ "$#" -eq 2 ] || usage
          [ -d "$dir" ] || { echo "msi-ec: driver not loaded" >&2; exit 1; }
          case "$1" in
            fan-mode) file=fan_mode; avail=$dir/available_fan_modes ;;
            shift-mode) file=shift_mode; avail=$dir/available_shift_modes ;;
            cooler-boost) file=cooler_boost; avail= ;;
            *) usage ;;
          esac
          if [ -n "$avail" ]; then
            ${pkgs.gnugrep}/bin/grep -qxF -- "$2" "$avail" || { echo "msi-ec: unsupported $1 $2" >&2; exit 2; }
          else
            [ "$2" = on ] || [ "$2" = off ] || usage
          fi
          printf '%s\n' "$2" | ${pkgs.coreutils}/bin/tee "$dir/$file" >/dev/null
          ${pkgs.coreutils}/bin/cat "$dir/$file"
        '')
        inputs.msi-tui.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      # Allow wheel to flip TLP power profiles without a password. Scoped to the
      # exact three subcommands; sudo already has a working setuid wrapper here
      # (pkexec does not), so this is the reliable escalation path.
      security.sudo.extraRules =
        [
          {
            groups = ["wheel"];
            commands = map (p: {
              command = "/run/current-system/sw/bin/tlp ${p}";
              options = ["NOPASSWD"];
            }) ["performance" "balanced" "power-saver"];
          }
        ]
        ++ lib.optionals msiEc [
          {
            groups = ["wheel"];
            commands =
              map (c: {
                command = "${msiEcCtl} ${c}";
                options = ["NOPASSWD"];
              }) (map (m: "fan-mode ${m}") fanModes
                ++ map (m: "shift-mode ${m}") shiftModes
                ++ ["cooler-boost on" "cooler-boost off"]);
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
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
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

        tlp.enable = true;
        tlp.pd.enable = true;
        tlp.settings =
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
}

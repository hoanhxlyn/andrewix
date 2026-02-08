{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aspects.utilities.enable {
    services = {
      power-profiles-daemon.enable = false;

      tlp = {
        enable = true;
        settings = {
          START_CHARGE_THRESH_BAT0 = 85;
          STOP_CHARGE_THRESH_BAT0 = 90;
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          USB_AUTOSUSPEND = 0;
        };
      };
    };
  };
}

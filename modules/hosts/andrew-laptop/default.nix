{ username, pkgs, ... }:

{
  imports = [
    ../../system/configuration.nix
    ./hardware-configuration.nix
  ];

  # Laptop specific hardware
  hardware.aic8800.enable = true;
  networking.hostName = "andrew-laptop";
  
  # Power Management (TLP)
  services.tlp = {
    enable = true;
    settings = {
      # Battery charge thresholds (85-90%)
      START_CHARGE_THRESH_BAT0 = 85;
      STOP_CHARGE_THRESH_BAT0 = 90;
      
      # CPU Governor settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # CPU Energy Performance Policy
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };
}

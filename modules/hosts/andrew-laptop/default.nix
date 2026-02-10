{...}: {
  imports = [
    ../../system/configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "andrew-laptop";
  hardware.aic8800.enable = true;
  aspects = {
    terminalEmulator = "wezterm";
  };
}

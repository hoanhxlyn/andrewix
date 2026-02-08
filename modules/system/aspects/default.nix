{lib, ...}: {
  imports = [
    ./core
    ./desktop
    ./gpu/nvidia.nix
    ./gaming
    ./utilities
  ];

  options.aspects = with lib; {
    desktop.enable = mkEnableOption "Desktop environment (GNOME)" // {default = true;};

    gpu.nvidia.enable = mkEnableOption "NVIDIA GPU driver support" // {default = false;};

    gaming.xone.enable = mkEnableOption "Xbox One controller driver" // {default = false;};

    utilities.enable = mkEnableOption "System utilities (browsers, power management, etc)" // {default = true;};
  };
}

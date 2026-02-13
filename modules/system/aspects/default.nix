{lib, ...}: {
  imports = [
    ./core
    ./core/stylix.nix
    ./desktop
    ./gpu/nvidia.nix
    ./gaming
    ./gaming/steam.nix
    ./utilities
  ];

  options.aspects = with lib; {
    stylix.enable = mkEnableOption "Stylix theming" // {default = true;};

    desktop.enable = mkEnableOption "Desktop environment (GNOME)" // {default = true;};

    gpu.nvidia.enable = mkEnableOption "NVIDIA GPU driver support" // {default = false;};

    gaming.xone.enable = mkEnableOption "Xbox One controller driver" // {default = false;};
    gaming.steam.enable = mkEnableOption "Steam gaming platform" // {default = false;};

    utilities.enable = mkEnableOption "System utilities (browsers, power management, etc)" // {default = true;};

    terminalEmulator = mkOption {
      type = types.enum ["wezterm" "alacritty" "none"];
      default = "none";
      description = "Choose which terminal emulator to enable (only one at a time).";
    };
  };
}

{
  config,
  lib,
  ...
}: let
  cfg = config.aspects;
in {
  imports =
    [
      ./core
    ]
    ++ lib.optional cfg.desktop.enable ./desktop
    ++ lib.optional cfg.gpu.nvidia.enable ./gpu/nvidia.nix
    ++ lib.optional cfg.gaming.xone.enable ./gaming
    ++ lib.optional cfg.utilities.enable ./utilities;

  options.aspects = with lib; {
    desktop.enable = mkEnableOption "Desktop environment (GNOME)" // {default = true;};

    gpu.nvidia.enable = mkEnableOption "NVIDIA GPU driver support" // {default = false;};

    gaming.xone.enable = mkEnableOption "Xbox One controller driver" // {default = false;};

    utilities.enable = mkEnableOption "System utilities (browsers, power management, etc)" // {default = true;};
  };
}

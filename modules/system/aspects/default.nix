{
  config,
  lib,
  ...
}: let
  cfg = config.aspects;
in {
  imports = [
    ./core
    {
      config = lib.mkIf cfg.desktop.enable {
        imports = [./desktop];
      };
    }
    {
      config = lib.mkIf cfg.gpu.nvidia.enable {
        imports = [./gpu/nvidia.nix];
      };
    }
    {
      config = lib.mkIf cfg.gaming.xone.enable {
        imports = [./gaming];
      };
    }
    {
      config = lib.mkIf cfg.utilities.enable {
        imports = [./utilities];
      };
    }
  ];

  options.aspects = with lib; {
    desktop.enable = mkEnableOption "Desktop environment (GNOME)" // {default = true;};

    gpu.nvidia.enable = mkEnableOption "NVIDIA GPU driver support" // {default = false;};

    gaming.xone.enable = mkEnableOption "Xbox One controller driver" // {default = false;};

    utilities.enable = mkEnableOption "System utilities (browsers, power management, etc)" // {default = true;};
  };
}

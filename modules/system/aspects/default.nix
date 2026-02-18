{
  lib,
  inputs,
  ...
}: {
  imports = [
    (inputs.import-tree.filterNot (path: baseNameOf path == "default.nix") ./.)
  ];

  options.aspects = with lib; {
    stylix.enable = mkEnableOption "Stylix theming" // {default = true;};
    desktop.enable = mkEnableOption "Desktop environment (GNOME)" // {default = true;};
    gpu.nvidia.enable = mkEnableOption "NVIDIA GPU driver support" // {default = false;};
    gaming = {
      xone.enable = mkEnableOption "Controller driver" // {default = false;};
      steam.enable = mkEnableOption "Steam gaming platform" // {default = false;};
    };
    utilities.enable = mkEnableOption "System utilities (browsers, power management, etc)" // {default = true;};
    fingerprint.enable = mkEnableOption "Fingerprint services" // {default = false;};
    terminal = {
      whichOne = mkOption {
        type = types.enum ["wezterm" "alacritty"];
        default = "none";
        description = "Choose which terminal emulator to enable (only one at a time).";
      };
      opacity = mkOption {
        type = types.float;
        default = 0.8;
        description = "Terminal window opacity";
      };
      fontSize = mkOption {
        type = types.int;
        default = 10;
        description = "Terminal font size";
      };
      padding = mkOption {
        type = types.int;
        default = 2;
        description = "Terminal window padding";
      };
    };
    dev = {
      neovim.enable = mkEnableOption "neovim" // {default = true;};
    };
  };
}

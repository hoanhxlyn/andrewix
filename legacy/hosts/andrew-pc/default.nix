{...}: {
  imports = [
    ../../system/configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "andrew-pc";
  hardware.aic8800.enable = true;

  aspects = {
    gpu.nvidia.enable = true;
    gaming.xone.enable = true;
    gaming.steam.enable = true;
    terminal.whichOne = "alacritty";
  };
}

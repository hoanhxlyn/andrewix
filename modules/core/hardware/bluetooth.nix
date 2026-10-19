{
  core.hardware.bluetooth.nixos = {pkgs, ...}: {
    hardware.bluetooth.enable = true;
    environment.systemPackages = [pkgs.bluetui];
  };
}

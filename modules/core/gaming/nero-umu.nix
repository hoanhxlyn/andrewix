{
  core.gaming.nero-umu = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.nero-umu];
    };
  };
}

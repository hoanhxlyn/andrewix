{
  andrew.communications.provides.caprine.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.caprine
    ];
  };
}

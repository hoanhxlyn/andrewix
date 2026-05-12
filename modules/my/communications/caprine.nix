{
  den.aspects.my.communications.caprine.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.caprine
    ];
  };
}

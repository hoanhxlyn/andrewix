{
  den.aspects.andrew._.communications._.caprine.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.caprine
    ];
  };
}

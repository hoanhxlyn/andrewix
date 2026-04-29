{
  den.aspects.my._.communications._.caprine.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.caprine
    ];
  };
}

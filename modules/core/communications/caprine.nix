{
  core.communications.caprine.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.caprine
    ];
  };
}

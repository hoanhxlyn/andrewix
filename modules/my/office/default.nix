{
  den.aspects.my.office = {
    teams.nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.teams-for-linux];
    };
  };
}

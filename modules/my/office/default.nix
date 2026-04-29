{
  den.aspects.my._.office._ = {
    teams.nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.teams-for-linux];
    };
  };
}

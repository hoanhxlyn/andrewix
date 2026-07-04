_: {
  core.office.teams.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.teams-for-linux];
  };
}

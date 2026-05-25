{__findFile, ...}: {
  den.aspects.my.office = {
    teams.nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.teams-for-linux];
    };
    markdown = {
      includes = [
        (<den/batteries/unfree> ["obsidian"])
      ];
      homeManager = {
        programs.obsidian.enable = true;
      };
    };
  };
}

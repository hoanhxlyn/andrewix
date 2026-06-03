{__findFile, ...}: {
  den.aspects.my.office = {
    teams.homeManager = {pkgs, ...}: {
      home.packages = [pkgs.teams-for-linux];
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

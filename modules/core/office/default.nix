{__findFile, ...}: {
  core.office = {
    teams.homeManager = {pkgs, ...}: {
      home.packages = [pkgs.teams-for-linux];
    };
    markdown = {
      includes = [
        (<den/batteries/unfree> ["obsidian"])
      ];
      homeManager = {
        programs.obsidian = {
          enable = true;
          defaultSettings = {
            appearance.nativeMenus = true;
            app.readableLineLength = false;
            app.strictLineBreaks = true;
          };
        };
      };
    };
  };
}
